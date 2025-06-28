# Algebrini Educational Game - Test Suite

This directory contains the complete test suite for the Algebrini educational game, organized into two main categories.

## 📁 Test Structure

```
tests/
├── unit/                    # Unit and Widget Tests
│   ├── games/              # Game logic tests
│   │   ├── simple_equations_game_test.dart
│   │   ├── recursive_sequences_game_test.dart
│   │   └── factorization_game_test.dart
│   ├── services/           # Service tests
│   │   ├── challenge_service_test.dart
│   │   ├── rewards_service_test.dart
│   │   ├── game_stats_service_test.dart
│   │   └── level_progression_service_test.dart
│   ├── screens/            # Widget tests
│   │   ├── settings_screen_test.dart
│   │   ├── progress_screen_test.dart
│   │   └── ...
│   └── ...
├── integration/            # Integration Tests
│   ├── app_test.dart       # Main integration tests
│   ├── web_test.dart       # Web-specific tests
│   ├── driver.dart         # Test driver
│   ├── test_config.dart    # Test utilities
│   └── README.md          # Integration test docs
└── README.md              # This file
```

## 🧪 Test Categories

### **Unit Tests** (`tests/unit/`)
- **Purpose**: Test individual components in isolation
- **Speed**: Fast (milliseconds per test)
- **Scope**: Functions, widgets, services
- **Use Case**: Development feedback, CI/CD pipeline

**Examples:**
- Game logic validation
- Service functionality
- Widget rendering
- Data processing

### **Integration Tests** (`tests/integration/`)
- **Purpose**: Test complete user flows
- **Speed**: Slower (seconds per test)
- **Scope**: Full app functionality
- **Use Case**: Quality assurance, regression testing

**Examples:**
- Complete game flows
- Cross-platform compatibility
- User interaction simulation
- End-to-end scenarios

## 🚀 Quick Start

### Run All Tests
```bash
task test-all
```

### Run Unit Tests Only
```bash
task test
```

### Run Integration Tests Only
```bash
task test-integration
```

### Run Tests with Coverage
```bash
task test-coverage
```

## 📋 Test Commands

### Basic Commands
```bash
task test                    # Unit tests only
task test-integration        # Integration tests only
task test-all                # All tests
task test-coverage           # Tests with coverage
```

### Platform-Specific
```bash
task test-integration-android # Android integration tests
task test-integration-web     # Web integration tests
task test-mobile              # Mobile-specific tests
task test-web                 # Web-specific tests
```

### Specialized Testing
```bash
task test-performance         # Performance tests
task test-accessibility       # Accessibility tests
task test-responsive          # Responsive design tests
task test-cross-platform      # Cross-platform tests
```

### Test Suites
```bash
task test-smoke               # Basic functionality
task test-nightly             # Comprehensive nightly tests
task test-weekly              # Extended weekly tests
task test-monthly             # Full regression tests
```

### Development
```bash
task test-watch               # Watch mode (auto-rerun)
task test-debug               # Verbose output
task test-specific -- path    # Run specific test file
task test-custom -- args      # Custom test parameters
```

## 🎯 Test Coverage

### Unit Tests Coverage
- ✅ **Game Logic**: All mini-games tested
- ✅ **Services**: Data storage, analytics, rewards
- ✅ **Widgets**: All screens and components
- ✅ **Accessibility**: Font size, TTS, themes
- ✅ **Business Logic**: Challenge system, progression

### Integration Tests Coverage
- ✅ **App Launch**: Startup and navigation
- ✅ **User Flows**: Complete game sessions
- ✅ **Cross-Platform**: Android and Web
- ✅ **Accessibility**: Full feature testing
- ✅ **Responsive Design**: Different screen sizes

## 🔧 Configuration

### Test Environment
- **Docker-based**: Consistent environment
- **Flutter 3.19.6**: Latest stable version
- **Multi-platform**: Linux, Web, Android support
- **Automated**: No manual intervention required

### Test Utilities
- **TestConfig**: Common test operations
- **Helper Functions**: Reusable test logic
- **Screen Size Testing**: Responsive design validation
- **Platform Detection**: Platform-specific tests

## 📊 Test Reports

### Coverage Reports
```bash
task test-coverage
# Generates: coverage/lcov.info
# View with: genhtml coverage/lcov.info -o coverage/html
```

### Test Reports
```bash
task test-report
# Generates: JSON format test results
```

### Performance Reports
```bash
task test-performance
# Generates: Performance metrics and timing data
```

## 🐛 Debugging

### Common Issues
1. **Timing Issues**: Use `TestConfig.waitForAnimations()`
2. **Widget Not Found**: Check visibility and positioning
3. **Platform Issues**: Use platform-specific conditionals
4. **Test Failures**: Check logs with `task test-debug`

### Debug Commands
```bash
task test-debug               # Verbose output
task test-watch               # Auto-rerun on changes
task test-clean               # Clean test artifacts
task test-setup               # Reset test environment
```

## 🔄 Continuous Integration

### GitHub Actions Example
```yaml
- name: Run Unit Tests
  run: task test

- name: Run Integration Tests
  run: task test-integration

- name: Generate Coverage
  run: task test-coverage
```

### CI/CD Pipeline
1. **Unit Tests**: Fast feedback (every commit)
2. **Integration Tests**: Quality gate (before merge)
3. **Full Suite**: Release validation (before deployment)

## 📈 Best Practices

### Writing Tests
1. **Use descriptive names** that explain the scenario
2. **Test one thing at a time** for clarity
3. **Use TestConfig utilities** for common operations
4. **Group related tests** using `group()`
5. **Test edge cases** and error conditions

### Test Organization
1. **Unit tests first** for fast development feedback
2. **Integration tests** for quality assurance
3. **Platform-specific tests** for compatibility
4. **Performance tests** for optimization

### Maintenance
1. **Keep tests up to date** with code changes
2. **Review test coverage** regularly
3. **Optimize test performance** for faster feedback
4. **Document test scenarios** for team understanding

## 🎉 Success Metrics

### Test Quality
- **Coverage**: >90% for critical paths
- **Speed**: Unit tests <30s, Integration tests <5min
- **Reliability**: <1% flaky tests
- **Maintainability**: Clear, documented test cases

### Development Efficiency
- **Fast Feedback**: Unit tests run in seconds
- **Confidence**: Integration tests validate user experience
- **Automation**: No manual testing required
- **Regression Prevention**: Catch bugs before users do

## 📚 Additional Resources

- [Integration Tests README](integration/README.md) - Detailed integration test documentation
- [Flutter Testing Guide](https://docs.flutter.dev/testing) - Official Flutter testing documentation
- [Taskfile Commands](Taskfile.yml) - Complete list of test commands

---

**Happy Testing! 🧪✨** 