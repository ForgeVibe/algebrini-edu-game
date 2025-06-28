# Algebrini Database Infrastructure

This directory contains the database infrastructure for the Algebrini educational game, supporting both development and production environments.

## 🏗️ Architecture

### Development Environment
- **PostgreSQL 15** - Primary database with optimized settings
- **Redis 7** - Caching and real-time features
- **pgAdmin 4** - Database management interface
- **Docker Compose** - Container orchestration

### Production Environment
- **PostgreSQL 15** - Production-optimized with monitoring
- **Redis 7** - Caching with authentication
- **pgAdmin 4** - Secure database management
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **Docker Compose** - Production container orchestration

## 📁 Directory Structure

```
infra/database/
├── dev/                    # Development environment
│   ├── docker-compose.yml  # Development containers
│   └── env.example        # Environment variables template
├── prod/                   # Production environment
│   ├── docker-compose.yml  # Production containers
│   └── env.example        # Production environment template
├── schemas/                # Database schemas
│   ├── init.sql           # Database initialization
│   └── seed.sql           # Initial data seeding
├── scripts/                # Database management scripts
│   ├── backup.sh          # Database backup script
│   └── restore.sh         # Database restore script
└── README.md              # This file
```

## 🚀 Quick Start

### Development Setup

1. **Start the development database:**
   ```bash
   task db:dev:start
   ```

2. **Check database status:**
   ```bash
   task db:dev:status
   ```

3. **Access pgAdmin:**
   - URL: http://localhost:8080
   - Email: admin@algebrini.dev
   - Password: admin_password

4. **Connect to PostgreSQL:**
   - Host: localhost
   - Port: 5432
   - Database: algebrini_dev
   - User: algebrini_user
   - Password: algebrini_dev_password

### Production Setup

1. **Configure environment:**
   ```bash
   cd infra/database/prod
   cp env.example .env
   # Edit .env with secure passwords
   ```

2. **Start production database:**
   ```bash
   task db:prod:start
   ```

3. **Access monitoring tools:**
   - pgAdmin: http://localhost:8080
   - Grafana: http://localhost:3000
   - Prometheus: http://localhost:9090

## 📊 Database Schema

### Core Tables

| Table | Description | Purpose |
|-------|-------------|---------|
| `games` | Game definitions | Store game metadata and configuration |
| `levels` | Level definitions | Game levels with difficulty and requirements |
| `challenges` | Game questions/problems | Individual challenges with answers and hints |
| `chapters` | Story chapters | Narrative progression and story content |
| `realms` | Story worlds | Visual themes and world descriptions |
| `cutscenes` | Story cutscenes | Narrative content and dialogue |
| `achievements` | Achievement definitions | Gamification and rewards |
| `users` | User accounts | Authentication and user management |
| `user_progress` | User progress tracking | Level completion and scores |
| `analytics_events` | User behavior tracking | Analytics and insights |

### Key Features

- **JSONB Support** - Flexible metadata storage
- **Full-text Search** - Search through content
- **Row Level Security** - Multi-tenant support
- **Performance Indexes** - Optimized queries
- **Audit Trails** - Automatic timestamp tracking

## 🔧 Management Commands

### Database Operations

```bash
# Development
task db:dev:start      # Start development database
task db:dev:stop       # Stop development database
task db:dev:restart    # Restart development database
task db:dev:status     # Show database status
task db:dev:reset      # Reset database (drop & recreate)
task db:dev:logs       # View database logs

# Production
task db:prod:start     # Start production database
task db:prod:stop      # Stop production database

# Backup & Restore
task db:backup         # Create database backup
task db:restore        # Restore from backup
task db:monitor        # Open monitoring tools
```

### Manual Operations

```bash
# Connect to database
psql -h localhost -p 5432 -U algebrini_user -d algebrini_dev

# Create backup
cd infra/database/scripts
./backup.sh algebrini_dev ./backups

# Restore backup
./restore.sh ./backups/algebrini_dev_20241201_120000.dump algebrini_dev
```

## 🔒 Security

### Development
- Default passwords (change for production)
- No SSL required
- Local access only

### Production
- Strong password requirements
- SSL/TLS encryption
- Network security
- Row Level Security (RLS)
- Audit logging

## 📈 Monitoring

### Production Monitoring Stack

1. **Prometheus** - Metrics collection
   - Database performance metrics
   - Query execution times
   - Connection statistics

2. **Grafana** - Visualization
   - Performance dashboards
   - User activity metrics
   - System health monitoring

3. **pgAdmin** - Database management
   - Query execution
   - Schema management
   - User administration

## 🔄 Data Migration

### Schema Updates

1. **Create migration script:**
   ```sql
   -- migrations/001_add_new_table.sql
   CREATE TABLE new_feature (
       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
       name VARCHAR(100) NOT NULL,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

2. **Apply migration:**
   ```bash
   psql -h localhost -p 5432 -U algebrini_user -d algebrini_dev -f migrations/001_add_new_table.sql
   ```

### Data Seeding

The `seed.sql` file contains initial data for:
- Games (recursive-sequences, simple-equations, factorization-fun)
- Story chapters and realms
- Achievements and challenge types
- Sample challenges for each game

## 🐛 Troubleshooting

### Common Issues

1. **Port conflicts:**
   ```bash
   # Check what's using the port
   sudo netstat -tulpn | grep :5432
   # Stop conflicting service
   sudo systemctl stop postgresql
   ```

2. **Permission issues:**
   ```bash
   # Fix script permissions
   chmod +x infra/database/scripts/*.sh
   ```

3. **Database connection:**
   ```bash
   # Test connection
   pg_isready -h localhost -p 5432 -U algebrini_user -d algebrini_dev
   ```

4. **Container issues:**
   ```bash
   # View logs
   task db:dev:logs
   
   # Reset containers
   task db:dev:reset
   ```

### Performance Tuning

1. **PostgreSQL Configuration:**
   - Shared buffers: 256MB (dev) / 512MB (prod)
   - Work memory: 4MB (dev) / 8MB (prod)
   - Maintenance work memory: 64MB (dev) / 128MB (prod)

2. **Indexing Strategy:**
   - B-tree indexes for equality queries
   - GIN indexes for JSONB and full-text search
   - Partial indexes for filtered queries

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

## 🤝 Contributing

When adding new database features:

1. **Update schema** in `schemas/init.sql`
2. **Add seed data** in `schemas/seed.sql`
3. **Update documentation** in this README
4. **Test migrations** in development environment
5. **Update backup/restore scripts** if needed

## 📄 License

This database infrastructure is part of the Algebrini educational game project. 