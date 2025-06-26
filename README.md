# Algebrini - Educational Algebra Game

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
task dev          # Development mode
task test         # Run tests
task build-web    # Build for web
task serve-web    # Serve production web app
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
task build-web
task build-android
```

## 🐳 Docker Development

### **Quick Docker Setup**
```bash
# Development mode
task dev

# Run tests
task test

# Build for production
task build-web
task serve-web
```

### **Manual Docker Commands**
```bash
# Build development image
docker build --target development -t algebrini:dev infra/docker/

# Run development server
docker run --rm -p 5000:5000 algebrini:dev

# Build production image
docker build --target production -t algebrini:prod infra/docker/

# Run production server
docker run --rm -p 80:80 algebrini:prod
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
task build-web

# Serve with nginx
task serve-web

# Or deploy to any static hosting service
```

### **Mobile Deployment**
```bash
# Build Android APK
task build-android

# Build iOS (requires macOS)
flutter build ios
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-feature`
3. **Make your changes**
4. **Run tests**: `task test`
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