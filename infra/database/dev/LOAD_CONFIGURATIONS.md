# Load Configuration Management

This directory contains dual configurations for different load scenarios in the Algebrini development environment.

## Quick Start

### Standard Configuration (Default)
```bash
# Start with standard configuration (good for development and moderate usage)
task load:standard
```

### High-Load Configuration
```bash
# Switch to high-load configuration (for heavy concurrent usage)
task load:high
```

## Configuration Comparison

| Feature | Standard | High-Load |
|---------|----------|-----------|
| **API Instances** | 1 | 3 + Load Balancer |
| **DB Connections** | 20 max, 5 min | 100 max, 20 min |
| **Redis Memory** | 256MB | 512MB |
| **Monitoring** | Disabled | Prometheus + Grafana |
| **Log Level** | Info | Warn |
| **Resource Limits** | None | 1GB RAM, 1 CPU |

## Manual Commands

### Standard Mode
```bash
cd infra/database/dev
export LOAD_LEVEL=standard
export ENABLE_METRICS=false
export LOG_LEVEL=info
docker compose up -d
```

### High-Load Mode
```bash
cd infra/database/dev
export LOAD_LEVEL=highLoad
export ENABLE_METRICS=true
export LOG_LEVEL=warn
docker compose -f compose.yml -f compose.high-load.yml up -d
```

## Services Available

### Standard Mode
- **API**: http://localhost:3000
- **Database**: localhost:5432
- **Redis**: localhost:6379
- **pgAdmin**: http://localhost:8081

### High-Load Mode
- **Load Balancer**: http://localhost:80
- **API 1**: http://localhost:3000
- **API 2**: http://localhost:3001
- **API 3**: http://localhost:3002
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3003 (admin/admin)
- **Database**: localhost:5432
- **Redis**: localhost:6379
- **pgAdmin**: http://localhost:8081

## Performance Monitoring

In high-load mode, you can monitor performance through:

1. **Prometheus**: http://localhost:9090
   - Collects metrics from all services
   - Stores time-series data

2. **Grafana**: http://localhost:3003
   - Username: `admin`
   - Password: `admin`
   - Pre-configured dashboards for API and database metrics

## When to Switch

### Use Standard Mode When:
- Development and testing
- < 100 concurrent users
- Limited system resources
- Simple debugging

### Use High-Load Mode When:
- Load testing
- > 100 concurrent users expected
- Performance optimization
- Production-like environment

## Configuration Files

- `compose.yml` - Base configuration
- `compose.high-load.yml` - High-load overrides
- `nginx.conf` - Load balancer configuration
- `prometheus.yml` - Monitoring configuration
- `env.standard` - Standard environment variables
- `env.high-load` - High-load environment variables

## Troubleshooting

### Check Current Configuration
```bash
task load:status
```

### Monitor Performance (High-load only)
```bash
task load:monitor
```

### Reset to Standard
```bash
task load:standard
```

### View Logs
```bash
# All services
docker compose -f infra/database/dev/compose.yml logs

# Specific service
docker compose -f infra/database/dev/compose.yml logs api
``` 