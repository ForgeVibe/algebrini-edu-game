#!/bin/bash

# Database restore script for Algebrini
# Usage: ./restore.sh [backup_file] [database_name]

set -e

# Configuration
BACKUP_FILE=${1}
DB_NAME=${2:-algebrini_dev}
LOG_FILE="./restore_$(date +"%Y%m%d_%H%M%S").log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

# Check if backup file exists
check_backup_file() {
    if [ -z "$BACKUP_FILE" ]; then
        error "Backup file not specified. Usage: $0 <backup_file> [database_name]"
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        error "Backup file not found: $BACKUP_FILE"
    fi
    
    log "Backup file: $BACKUP_FILE"
    log "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
}

# Check if PostgreSQL is running
check_postgres() {
    if ! pg_isready -U algebrini_user >/dev/null 2>&1; then
        error "PostgreSQL is not running or not accessible"
    fi
}

# Confirm restore operation
confirm_restore() {
    echo -e "${YELLOW}WARNING: This will overwrite the database '$DB_NAME'${NC}"
    echo -e "${YELLOW}All existing data will be lost!${NC}"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log "Restore cancelled by user"
        exit 0
    fi
}

# Drop and recreate database
prepare_database() {
    log "Preparing database: $DB_NAME"
    
    # Drop database if it exists
    if psql -U algebrini_user -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        log "Dropping existing database: $DB_NAME"
        dropdb -U algebrini_user "$DB_NAME" 2>> "$LOG_FILE" || warning "Failed to drop database"
    fi
    
    # Create new database
    log "Creating new database: $DB_NAME"
    createdb -U algebrini_user "$DB_NAME" 2>> "$LOG_FILE" || error "Failed to create database"
}

# Perform the restore
perform_restore() {
    log "Starting restore of database: $DB_NAME"
    
    # Determine backup format and restore accordingly
    if [[ "$BACKUP_FILE" == *.dump ]]; then
        # Custom format backup
        pg_restore -U algebrini_user -d "$DB_NAME" \
            --verbose \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            "$BACKUP_FILE" \
            2>> "$LOG_FILE"
    else
        # Plain SQL backup
        psql -U algebrini_user -d "$DB_NAME" \
            -f "$BACKUP_FILE" \
            2>> "$LOG_FILE"
    fi
    
    if [ $? -eq 0 ]; then
        log "Restore completed successfully"
    else
        error "Restore failed"
    fi
}

# Verify restore
verify_restore() {
    log "Verifying restore..."
    
    # Check if database exists and has tables
    table_count=$(psql -U algebrini_user -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    
    if [ "$table_count" -gt 0 ]; then
        log "Restore verification successful. Found $table_count tables."
    else
        warning "Restore verification failed. No tables found."
    fi
}

# Main execution
main() {
    log "=== Algebrini Database Restore Started ==="
    
    check_backup_file
    check_postgres
    confirm_restore
    prepare_database
    perform_restore
    verify_restore
    
    log "=== Restore completed successfully ==="
    log "Database: $DB_NAME"
    log "Log file: $LOG_FILE"
}

# Run main function
main "$@" 