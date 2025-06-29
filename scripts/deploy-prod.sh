#!/bin/bash

# Production Deployment Script for Algebrini
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="algebrini"
BACKUP_DIR="./backups"
LOG_FILE="./deploy.log"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    if ! docker compose version &> /dev/null; then
        error "Docker Compose is not available"
    fi
    
    if [ ! -f "infra/database/prod/compose.yml" ]; then
        error "Production compose file not found"
    fi
    
    if [ ! -f "infra/database/prod/.env" ]; then
        error "Production environment file not found"
    fi
    
    success "Prerequisites check passed"
}

# Create backup
create_backup() {
    log "Creating database backup..."
    
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).sql"
    
    if docker compose -f infra/database/prod/compose.yml exec -T postgres pg_dump -U algebrini_user algebrini_prod > "$BACKUP_FILE" 2>/dev/null; then
        success "Backup created: $BACKUP_FILE"
    else
        warning "Could not create backup (database might not be running)"
    fi
}

# Stop existing services
stop_services() {
    log "Stopping existing services..."
    
    if docker compose -f infra/database/prod/compose.yml down --remove-orphans; then
        success "Services stopped"
    else
        warning "Some services might not have been running"
    fi
}

# Pull latest images
pull_images() {
    log "Pulling latest images..."
    
    if docker compose -f infra/database/prod/compose.yml pull; then
        success "Images pulled successfully"
    else
        error "Failed to pull images"
    fi
}

# Build and start services
deploy_services() {
    log "Building and starting services..."
    
    if docker compose -f infra/database/prod/compose.yml up -d --build; then
        success "Services started successfully"
    else
        error "Failed to start services"
    fi
}

# Wait for services to be healthy
wait_for_health() {
    log "Waiting for services to be healthy..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker compose -f infra/database/prod/compose.yml ps | grep -q "healthy"; then
            success "All services are healthy"
            return 0
        fi
        
        log "Waiting for services to be healthy... (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    error "Services failed to become healthy within expected time"
}

# Run health checks
run_health_checks() {
    log "Running health checks..."
    
    # Check API health
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        success "API health check passed"
    else
        error "API health check failed"
    fi
    
    # Check database connection
    if docker compose -f infra/database/prod/compose.yml exec -T postgres pg_isready -U algebrini_user -d algebrini_prod > /dev/null 2>&1; then
        success "Database health check passed"
    else
        error "Database health check failed"
    fi
    
    # Check Redis connection
    if docker compose -f infra/database/prod/compose.yml exec -T redis redis-cli ping > /dev/null 2>&1; then
        success "Redis health check passed"
    else
        error "Redis health check failed"
    fi
}

# Rollback function
rollback() {
    log "Rolling back deployment..."
    
    # Stop current services
    docker compose -f infra/database/prod/compose.yml down --remove-orphans
    
    # Restore from backup if available
    if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
        log "Restoring database from backup..."
        docker compose -f infra/database/prod/compose.yml up -d postgres
        sleep 10
        docker compose -f infra/database/prod/compose.yml exec -T postgres psql -U algebrini_user -d algebrini_prod < "$BACKUP_FILE"
    fi
    
    error "Deployment rolled back"
}

# Main deployment function
main() {
    log "Starting production deployment..."
    
    # Set up error handling
    trap rollback ERR
    
    # Run deployment steps
    check_prerequisites
    create_backup
    stop_services
    pull_images
    deploy_services
    wait_for_health
    run_health_checks
    
    # Remove error trap on success
    trap - ERR
    
    success "Production deployment completed successfully!"
    log "Services are running and healthy"
    log "API: http://localhost:3000"
    log "Health check: http://localhost:3000/health"
}

# Run main function
main "$@" 