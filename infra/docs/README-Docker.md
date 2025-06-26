# Algebrini Docker Environment - MVP Setup

This Docker environment provides a complete, reproducible setup for developing, testing, and building the Algebrini educational game across all MVP target platforms.

## 🎯 What This Environment Provides

### ✅ **Full MVP Support**
- **Cross-platform development:** Android, iOS, Web
- **Automated testing:** Unit, widget, and integration tests
- **CI/CD ready:** Automated build and test pipelines
- **Production builds:** Web deployment with nginx
- **Local development:** Hot reload and debugging

### 🏗️ **Multi-Stage Docker Builds**
- `development`: Interactive development with hot reload
- `testing`: Run all tests with coverage
- `web-build`: Build optimized web app
- `android-build`: Build Android APK
- `production`: Production web server with nginx

## 🚀 Quick Start

### **Prerequisites**
- Docker installed and running
- Task (Taskfile runner) installed: https://taskfile.dev/installation/

### 1. **Development Mode** (Default)
```bash
task dev
```
- Builds development environment
- Starts Flutter web server on http://localhost:5000
- Hot reload enabled

### 2. **Run Tests**
```bash
task test
```
- Runs all Flutter tests
- Generates coverage reports
- Exits with test results

### 3. **Build for Production**
```bash
# Build web app
task build-web

# Serve production web app
task serve-web
```

### 4. **Build Android APK**
```bash
task build-android
```

### 5. **CI/CD Pipeline**
```bash
task ci
```
- Runs all tests
- Builds web and Android versions
- Perfect for automated pipelines

## 📋 Available Commands

| Command | Description | Use Case |
|---------|-------------|----------|
| `task dev` | Development mode with hot reload | Local development |
| `task test` | Run all tests with coverage | Quality assurance |
| `task build-web` | Build optimized web app | Production deployment |
| `task build-android` | Build Android APK | Mobile distribution |
| `task serve-web` | Serve web app with nginx | Production hosting |
| `task ci` | Full CI/CD pipeline | Automated testing |
| `task clean` | Clean Docker resources | Maintenance |
| `task clean-all` | Clean everything including Flutter SDK | Complete reset |
| `task docs` | Show all available tasks | Documentation |
| `task help` | Show detailed help | Documentation |

## 🔧 Manual Docker Commands

### Build Specific Targets
```bash
# Development
docker build --target development -t algebrini:dev infra/docker/

# Testing
docker build --target testing -t algebrini:test infra/docker/

# Web build
docker build --target web-build -t algebrini:web infra/docker/

# Android build
docker build --target android-build -t algebrini:android infra/docker/

# Production
docker build --target production -t algebrini:prod infra/docker/
```

### Run Containers
```bash
# Development server
docker run --rm -p 5000:5000 algebrini:dev

# Run tests
docker run --rm algebrini:test

# Production web server
docker run --rm -p 80:80 algebrini:prod
```

## 🌐 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Development | http://localhost:5000 | Flutter web dev server |
| Production | http://localhost:80 | Nginx production server |
| Health Check | http://localhost:80/health | Server health status |

## 📁 Project Structure

```
algebrini-edu-game/
├── Taskfile.yml              # Task orchestration
├── lib/                      # Flutter app source code
├── assets/                   # App assets
├── test/                     # App tests
├── infra/                    # Infrastructure
│   ├── docker/
│   │   ├── Dockerfile        # Multi-stage Docker build
│   │   ├── nginx.conf        # Production web server config
│   │   └── .dockerignore     # Docker build exclusions
│   ├── downloads/            # Downloaded dependencies
│   │   └── flutter_linux_*.tar.xz # Flutter SDK archive
│   ├── scripts/
│   │   └── test_automation.sh # Legacy bash script
│   └── docs/
│       └── README-Docker.md  # This file
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # Main project README
```

## 🔍 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using port 5000
   lsof -i :5000
   
   # Use different port
   docker run -p 8080:5000 algebrini:dev
   ```

2. **Build fails due to memory**
   ```bash
   # Increase Docker memory limit
   # Or use swap space
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

3. **Android build issues**
   - Android builds require additional setup
   - May not work in all environments
   - Consider using GitHub Actions for Android builds

4. **Task not found**
   ```bash
   # Install Task
   # Linux/macOS
   sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
   
   # Or use package manager
   # Ubuntu/Debian
   sudo snap install task --classic
   ```

### Clean Up
```bash
# Remove all related images
task clean

# Remove everything including Flutter SDK
task clean-all

# Or manually
docker system prune -f
docker rmi algebrini-flutter:*
```

## 🎯 MVP Feature Coverage

| MVP Requirement | Docker Support | Status |
|-----------------|----------------|--------|
| Cross-platform (Web) | ✅ Full | Production-ready |
| Cross-platform (Android) | ✅ Build | APK generation |
| Cross-platform (iOS) | ⚠️ Structure | Requires macOS |
| Automated testing | ✅ Full | Unit, widget, integration |
| CI/CD ready | ✅ Full | Complete pipeline |
| Local development | ✅ Full | Hot reload, debugging |
| Production deployment | ✅ Full | Nginx server |

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Algebrini CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Install Task
        run: go install github.com/go-task/task/v3/cmd/task@latest
      - name: Run CI pipeline
        run: task ci
```

### GitLab CI Example
```yaml
stages:
  - test
  - build

variables:
  TASK_VERSION: "3.34.1"

before_script:
  - curl -sL https://taskfile.dev/install.sh | sh
  - export PATH="$HOME/.local/bin:$PATH"

test:
  stage: test
  script:
    - task test

build:
  stage: build
  script:
    - task build-web
```

## 📚 Next Steps

1. **Add your Flutter app code** to the `lib/` directory
2. **Run development mode** to start coding: `task dev`
3. **Add tests** in the `test/` directory
4. **Customize nginx.conf** for your domain
5. **Set up CI/CD** with your preferred platform

## 🤝 Contributing

This Docker environment is designed to make contribution easy:
- No local Flutter installation required
- Consistent environment for all developers
- Automated testing and building
- Clear documentation and examples
- Simple Taskfile commands for all operations

## 🔄 Migration from Bash Script

If you were using the old `test_automation.sh` script:

| Old Command | New Command |
|-------------|-------------|
| `./test_automation.sh dev` | `task dev` |
| `./test_automation.sh test` | `task test` |
| `./test_automation.sh build-web` | `task build-web` |
| `./test_automation.sh ci` | `task ci` |
| `./test_automation.sh clean` | `task clean` |

The old script is still available at `infra/scripts/test_automation.sh` for reference.

---

**Happy coding with Algebrini! 🧙‍♂️✨** 