# Load Configuration Quick Reference

## 🚀 Quick Commands

```bash
# Switch to standard configuration (development)
task load:standard

# Switch to high-load configuration (production-like)
task load:high

# Check current configuration
task load:status
```

## 📊 Configuration Comparison

| Feature | Standard | High-Load |
|---------|----------|-----------|
| **API Instances** | 1 | 3 |
| **DB Connections** | 20 max, 5 min | 100 max, 20 min |
| **Redis Memory** | 256MB | 512MB |
| **Monitoring** | None | Prometheus + Grafana |
| **Load Balancer** | None | Nginx |

## 🌐 Service Endpoints

### Standard Mode
- **API**: http://localhost:3000
- **Database**: localhost:5432
- **Redis**: localhost:6379
- **pgAdmin**: http://localhost:8081

### High-Load Mode
- **API 1**: http://localhost:3000
- **API 2**: http://localhost:3001
- **API 3**: http://localhost:3002
- **Load Balancer**: http://localhost:80
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3003 (admin/admin)

## 📖 Full Documentation

For complete documentation, see: `infra/database/dev/LOAD_CONFIGURATIONS.md` 