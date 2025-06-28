#!/bin/bash

# Database backup script for Algebrini
# Usage: ./backup.sh [database_name] [backup_dir]

set -e

# Configuration
DB_NAME=${1:-algebrini_dev}
BACKUP_DIR=${2:-./backups}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/algebrini_${DB_NAME}_${TIMESTAMP}.sql"
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

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

# Check if PostgreSQL is running
check_postgres() {
    if ! pg_isready -U algebrini_user -d "$DB_NAME" >/dev/null 2>&1; then
        error "PostgreSQL is not running or not accessible"
    fi
}

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Perform the backup
perform_backup() {
    log "Starting backup of database: $DB_NAME"
    log "Backup file: $BACKUP_FILE"
    
    # Create backup with custom format for better compression
    pg_dump -U algebrini_user -d "$DB_NAME" \
        --verbose \
        --clean \
        --if-exists \
        --create \
        --format=custom \
        --file="${BACKUP_FILE}.dump" \
        --compress=9 \
        2>> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log "Backup completed successfully"
        log "Backup size: $(du -h "${BACKUP_FILE}.dump" | cut -f1)"
    else
        error "Backup failed"
    fi
}

# Cleanup old backups (keep last 7 days)
cleanup_old_backups() {
    log "Cleaning up backups older than 7 days"
    find "$BACKUP_DIR" -name "algebrini_*.dump" -mtime +7 -delete 2>/dev/null || warning "Failed to cleanup old backups"
}

# Main execution
main() {
    log "=== Algebrini Database Backup Started ==="
    
    create_backup_dir
    check_postgres
    perform_backup
    cleanup_old_backups
    
    log "=== Backup completed successfully ==="
    log "Backup file: ${BACKUP_FILE}.dump"
    log "Log file: $LOG_FILE"
}

# Run main function
main "$@" 