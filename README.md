# Algebrini - Educational Algebra Game

> **BREAKING CHANGE (vNext):**
> - The Taskfile and Docker workflow have changed. See the updated sections below for new commands and usage.
> - Use `task help` or see the "Taskfile Commands" section for all available automation tasks.
> - Container management is now safer and only targets Algebrini containers.

An interactive Flutter game designed to teach algebra concepts to children aged 9-13 through engaging mini-games and progressive learning.

## 🎯 MVP Features

### ✅ **Core Features Implemented**
- **Localization**: Multi-language support (English, French, Spanish)
- **User Profile Management**: Save/load user progress and preferences
- **Interactive Mini-Games**: 
  - Recursive Sequences: Pattern recognition and sequence completion
  - Simple Equations: Step-by-step equation solving with hints
- **Progress Tracking**: Save game progress and achievements
- **Rewards System**: Points, badges, and unlockable content
- **Accessibility**: High contrast mode, larger text options
- **Support**: In-game help and tutorials

### 🎮 **Mini-Games**
1. **Recursive Sequences**: Players identify patterns and complete sequences
2. **Simple Equations**: Step-by-step equation solving with visual feedback

## 🚀 Quick Start

### **Option 1: Using Task (Recommended)**
```bash
# Install Task: https://taskfile.dev/installation/
# Then run:
task dev:setup     # Complete development environment setup
task dev:start     # Development mode (background)
task dev:start-fg  # Development mode (foreground)
task test          # Run tests
task build:web     # Build for web
task serve-web     # Serve production web app

# Load Configuration (for different usage scenarios):
task load:standard # Standard configuration (development)
task load:high     # High-load configuration (heavy usage)
```

### **Option 2: Local Flutter Development**
```bash
# Install Flutter SDK
flutter pub get
flutter run -d chrome
```

### **Option 3: Docker Environment**
```bash
# Build and run with Docker
docker build -t algebrini infra/docker/
docker run -p 5000:5000 algebrini
```

## 📁 Project Structure

```
algebrini-edu-game/
├── Taskfile.yml              # Task orchestration (replaces bash scripts)
├── lib/                      # Flutter app source code
│   ├── main.dart             # App entry point
│   ├── models/               # Data models
│   ├── screens/              # UI screens
│   ├── widgets/              # Reusable widgets
│   ├── services/             # Business logic
│   └── utils/                # Utilities and helpers
├── assets/                   # App assets (images, fonts, etc.)
├── test/                     # App tests
├── infra/                    # Infrastructure and deployment
│   ├── docker/               # Docker configuration
│   │   ├── Dockerfile        # Multi-stage Docker build
│   │   ├── nginx.conf        # Production web server
│   │   └── .dockerignore     # Docker exclusions
│   ├── downloads/            # Downloaded dependencies
│   │   └── flutter_linux_*.tar.xz # Flutter SDK archive
│   ├── scripts/              # Legacy scripts
│   │   └── test_automation.sh # Bash automation (deprecated)
│   └── docs/                 # Infrastructure documentation
│       └── README-Docker.md  # Docker setup guide
├── docs/                     # Project documentation
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # This file
```

## 🎮 Game Features

### **User Experience**
- **Intuitive Interface**: Child-friendly design with clear navigation
- **Progressive Difficulty**: Games adapt to user skill level
- **Immediate Feedback**: Visual and audio feedback for all actions
- **Tutorial System**: Guided learning for new concepts

### **Educational Content**
- **Algebra Fundamentals**: Variables, equations, patterns
- **Visual Learning**: Interactive diagrams and animations
- **Problem Solving**: Step-by-step guidance and hints
- **Practice Mode**: Unlimited practice with different problems

### **Accessibility**
- **High Contrast Mode**: Better visibility for visual impairments
- **Larger Text**: Adjustable font sizes
- **Keyboard Navigation**: Full keyboard support
- **Screen Reader Support**: Compatible with assistive technologies

## 🛠️ Development

### **Prerequisites**
- Flutter SDK 3.19.6 or higher
- Dart SDK (included with Flutter)
- Chrome browser (for web development)
- Task (for automated workflows)

### **Setup**
```bash
# Clone the repository
git clone <repository-url>
cd algebrini-edu-game

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### **Testing**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Or use Task
task test
```

### **Building**
```bash
# Build for web
flutter build web

# Build for Android
flutter build apk

# Or use Task
task build:web
task build:android
```

## 🛠️ Taskfile Commands

The project uses [Task](https://taskfile.dev/) for all development, build, and CI automation. Tasks are organized into logical categories with prefixes:

### **Development Environment (`dev:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| dev:setup           | Complete development environment setup           |
| dev:start           | Start development server (background)            |
| dev:start-fg        | Start development server (foreground)            |
| dev:stop            | Stop development server                          |
| dev:restart         | Restart development server                       |
| dev:reset           | Reset development environment                    |
| dev:logs            | View development server logs                     |

### **Legacy Aliases (for backward compatibility)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| dev                 | Alias for dev:start                              |
| dev-fg              | Alias for dev:start-fg                           |

### **Environment Status (`env:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| env:status          | Check development environment status             |

### **Testing (`test:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| test                | Run all tests with coverage                      |
| test:unit           | Run unit tests                                   |
| test:integration    | Run integration tests                            |
| test:coverage       | Generate test coverage report                    |
| test:smoke          | Run smoke tests (basic functionality)            |
| test:regression     | Run regression tests                             |
| test:performance    | Run performance tests                            |
| test:accessibility  | Run accessibility tests                          |
| test:responsive     | Run responsive design tests                      |
| test:mobile         | Run mobile-specific tests                        |
| test:web            | Run web-specific tests                           |
| test:nightly        | Run nightly test suite                           |
| test:weekly         | Run weekly test suite                            |
| test:monthly        | Run monthly test suite                           |
| test:database       | Test database integration                        |

### **Build (`build:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| build:web           | Build web app for production                     |
| build:android       | Build Android APK                                |
| build:ios           | Build iOS app (requires macOS)                   |
| build:all           | Build for all platforms                          |

### **Code Quality (`code:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| code:format         | Format Dart code                                 |
| code:analyze        | Analyze Dart code                                |
| code:lint           | Run linting                                      |
| code:fix            | Format and analyze code                          |

### **Database Management (`db:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| db:start            | Start database stack                             |
| db:stop             | Stop database stack                              |
| db:status           | Check database status                            |
| db:backup           | Create database backup                           |
| db:restore          | Restore database                                 |
| db:logs             | Show database logs                               |
| db:monitor          | Monitor database performance                     |
| db:restart          | Restart database stack                           |

### **API Management (`api:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| api:install         | Install API dependencies                         |
| api:start           | Start API server                                 |
| api:stop            | Stop API server                                  |
| api:status          | Check API status                                 |
| api:test            | Test API endpoints                               |

### **Load Configuration (`load:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| load:standard       | Switch to standard configuration (1 API instance) |
| load:high           | Switch to high-load configuration (3 API instances + monitoring) |
| load:status         | Check current load configuration status          |

**Load Configuration Details:**
- **Standard Mode**: 20 DB connections, 256MB Redis, single API instance
- **High-Load Mode**: 100 DB connections, 512MB Redis, 3 API instances, load balancer, Prometheus + Grafana monitoring
- See `infra/database/dev/LOAD_CONFIGURATIONS.md` for complete documentation

### **Dependencies (`deps:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| deps:get            | Get Flutter dependencies                         |
| deps:upgrade        | Upgrade Flutter dependencies                     |
| deps:outdated       | Check for outdated dependencies                  |

### **Production (`serve-web`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| serve-web           | Serve production web app with nginx              |

### **Maintenance**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| clean               | Clean Docker resources                           |
| clean-all           | Clean everything including Flutter SDK           |
| stop-all            | Stop all Algebrini containers                    |

### **CI/CD (`ci:*`)**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| ci                  | Run complete CI/CD pipeline                      |
| ci:test             | Run CI test suite                                |
| ci:build            | Run CI build                                     |

### **Utility**
| Task                | Description                                      |
|---------------------|--------------------------------------------------|
| help                | Show available tasks                             |
| status              | Show development environment status              |

Run `task <taskname>` to execute a task. For example:
```bash
task dev:start
task test
task build:web
```

## 🔄 Development Workflow

### **Initial Setup (First Time)**
```bash
# 1. Complete development environment setup
task dev:setup

# 2. Start development server
task dev:start

# 3. Access the app at http://localhost:5052
```

### **Daily Development Workflow**
```bash
# Start development server (background)
task dev:start

# View logs to monitor the app
task dev:logs

# Stop development server when done
task dev:stop
```

### **When Code Changes Don't Reflect**
If you make code changes but they don't appear in the running app:

```bash
# 1. Stop the development server
task dev:stop

# 2. Rebuild the Docker image (if needed)
task docker:build-dev

# 3. Restart the development server
task dev:start

# 4. Check logs for any errors
task dev:logs
```

### **Complete Reset (When Things Go Wrong)**
If you encounter persistent issues or want a completely fresh start:

```bash
# 1. Stop all containers
task dev:stop

# 2. Clean Docker system
docker system prune -f

# 3. Remove development image
docker rmi algebrini-flutter:development

# 4. Rebuild everything from scratch
task docker:build-dev

# 5. Regenerate build_runner outputs
task deps:build-runner

# 6. Start fresh development server
task dev:start
```

### **Code Quality Workflow**
```bash
# Format and analyze code
task code:fix

# Run tests
task test

# Regenerate generated files (if needed)
task deps:build-runner
```

### **Production Build Workflow**
```bash
# Build for web
task build:web

# Serve production web app
task serve-web
```

### **Troubleshooting Common Issues**

#### **App Hangs on Loading Screen**
```bash
# Check container logs
task dev:logs

# If there are compilation errors, fix them and restart
task dev:stop
task dev:start
```

#### **Code Changes Not Reflecting**
```bash
# Force rebuild and restart
task dev:stop
task docker:build-dev
task dev:start
```

#### **Build Errors**
```bash
# Clean and rebuild
task dev:stop
docker system prune -f
task docker:build-dev
task deps:build-runner
task dev:start
```

#### **Port Already in Use**
```bash
# Check what's using the port
lsof -i :5052

# Stop conflicting processes or use different port
# (Port configuration is in Taskfile.yml)
```

### **Environment Status**
```bash
# Check if development environment is running
task env:status

# View all running containers
docker ps

# Check Docker image status
docker images | grep algebrini
```

## 🐳 Docker Development (Updated)

### **Quick Docker Setup (Recommended)**
```bash
# Complete setup (first time or when you need database/API)
task dev:setup

# Start development server (background)
task dev:start

# Start development server (foreground with hot reload)
task dev:start-fg

# View logs
task dev:logs

# Stop development server
task dev:stop

# Build for production
task build:web
task serve-web
```

### **Safer Container Management**
- `task dev:stop` and `task stop-all` only affect Algebrini containers, not your entire Docker environment.
- Use `task clean` to remove only Algebrini images and containers.

### **Manual Docker Commands (Advanced)**
```bash
# Build development image
docker build --target development -t algebrini-flutter:development infra/docker/

# Run development server
docker run --rm -p 5000:5000 algebrini-flutter:development

# Build production image
docker build --target production -t algebrini-flutter:production infra/docker/

# Run production server
docker run --rm -p 80:80 algebrini-flutter:production
```

## 📊 MVP Progress

| Feature | Status | Implementation |
|---------|--------|----------------|
| Localization | ✅ Complete | Multi-language support with JSON files |
| User Profile | ✅ Complete | Local storage with preferences |
| Mini-Games | ✅ Complete | Interactive Recursive Sequences & Equations |
| Progress Tracking | ✅ Complete | Save/load game state |
| Rewards System | ✅ Complete | Points, badges, achievements |
| Accessibility | ✅ Complete | High contrast, large text, keyboard nav |
| Support | ✅ Complete | In-game help and tutorials |
| Cross-platform | ✅ Complete | Web, Android, iOS ready |
| Testing | ✅ Complete | Unit, widget, integration tests |
| CI/CD | ✅ Complete | Automated build and test pipeline |

## 🎯 Educational Goals

### **Learning Objectives**
- **Pattern Recognition**: Identify mathematical patterns and sequences
- **Variable Understanding**: Learn to work with unknown values
- **Equation Solving**: Step-by-step problem-solving approach
- **Logical Thinking**: Develop mathematical reasoning skills
- **Confidence Building**: Progressive difficulty builds confidence

### **Age-Appropriate Content**
- **9-10 years**: Basic patterns and simple equations
- **11-12 years**: More complex sequences and multi-step equations
- **13 years**: Advanced patterns and equation systems

## 🔧 Configuration

### **Environment Variables**
```bash
# Development
FLUTTER_ENV=development

# Production
FLUTTER_ENV=production
```

### **Localization**
Add new languages by creating files in `assets/translations/`:
```json
{
  "game_title": "Algebrini",
  "play": "Play",
  "settings": "Settings"
}
```

## 🚀 Deployment

### **Web Deployment**
```bash
# Build for production
task build:web

# Serve with nginx
task deploy:web

# Or deploy to any static hosting service
```

### **Mobile Deployment**
```bash
# Build Android APK
task build:android

# Build iOS (requires macOS)
flutter build ios
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-feature`
3. **Make your changes**
4. **Run tests**: `task test:run`
5. **Commit your changes**: `git commit -am 'Add new feature'`
6. **Push to the branch**: `git push origin feature/new-feature`
7. **Submit a pull request**

### **Development Guidelines**
- Follow Flutter best practices
- Write tests for new features
- Update documentation
- Use meaningful commit messages
- Test on multiple platforms

## 📚 Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Docker Documentation](https://docs.docker.com/)
- [Task Documentation](https://taskfile.dev/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Educational game developers community
- Beta testers and feedback providers

---

**Making algebra fun, one game at a time! 🧙‍♂️✨**