# Algebrini Integration Tests

This directory contains comprehensive integration tests for the Algebrini educational game, covering both Android mobile and Web platforms.

## Overview

The integration tests simulate real user interactions and verify that all app features work correctly across different platforms and screen sizes.

## Test Structure

```
tests/
├── unit/                    # Unit and widget tests
│   ├── games/              # Game logic tests
│   ├── services/           # Service tests
│   ├── screens/            # Widget tests
│   └── ...
├── integration/            # Integration tests (this folder)
│   ├── app_test.dart       # Main integration tests for all platforms
│   ├── web_test.dart       # Web-specific tests
│   ├── driver.dart         # Test driver for flutter drive
│   ├── test_config.dart    # Test configuration and utilities
│   └── README.md          # This file
```

## Test Coverage

### Core App Flows
- ✅ App launch and navigation
- ✅ Tab navigation (Play, Challenges, Progress, Profile, Settings)
- ✅ Game selection and level progression
- ✅ Challenge system (Daily, Weekly, History)
- ✅ Settings and accessibility features
- ✅ Rewards and progress tracking
- ✅ Challenge completion and reward claiming
- ✅ Progress analytics and export
- ✅ Home screen challenge widget
- ✅ Game hint system
- ✅ Text-to-Speech functionality
- ✅ Level unlocking system

### Web-Specific Features
- ✅ Responsive design across different screen sizes
- ✅ Web navigation with larger screens
- ✅ Keyboard input handling
- ✅ Web-specific settings
- ✅ Cross-platform compatibility

### Platform Testing
- ✅ Android mobile app testing
- ✅ Web app testing
- ✅ Responsive design testing
- ✅ Cross-platform compatibility

## Running Tests

### Prerequisites
- Flutter SDK installed
- Docker environment set up
- Taskfile available

### Basic Commands

```bash
# Run all integration tests
task test-integration

# Run Android-specific tests
task test-integration-android

# Run Web-specific tests
task test-integration-web

# Run all tests (unit + integration)
task test-all

# Run tests with coverage
task test-coverage
```

### Advanced Commands

```bash
# Run tests in watch mode
task test-watch

# Run tests with debug output
task test-debug

# Run specific test file
task test-specific -- tests/integration/app_test.dart

# Run custom test suite
task test-custom -- --dart-define=platform=web --dart-define=test_type=smoke

# Run tests with flutter drive (for device testing)
task test-integration-drive

# Run web tests with flutter drive
task test-integration-web-drive
```

### Test Suites

```bash
# Smoke tests (basic functionality)
task test-smoke

# Performance tests
task test-performance

# Accessibility tests
task test-accessibility

# Responsive design tests
task test-responsive

# Cross-platform tests
task test-cross-platform

# Nightly test suite (comprehensive)
task test-nightly

# Weekly test suite (extended)
task test-weekly

# Monthly test suite (full regression)
task test-monthly
```

## Test Configuration

### Screen Sizes
The tests automatically adapt to different screen sizes:
- Mobile: 375x667
- Tablet: 768x1024
- Desktop: 1920x1080
- Web: 1200x800

### Test Utilities
The `test_config.dart` file provides helper functions:
- `TestConfig.waitForAnimations()` - Wait for animations to complete
- `TestConfig.tapAndWait()` - Tap and wait for animations
- `TestConfig.enterTextAndWait()` - Enter text and wait
- `TestConfig.completeGameLevel()` - Complete a game level
- `TestConfig.navigateToTab()` - Navigate to a specific tab
- `TestConfig.setScreenSize()` - Set screen size for testing

## Test Scenarios

### 1. App Launch and Navigation
- Verifies app launches correctly
- Tests navigation between all tabs
- Ensures all main screens are accessible

### 2. Game System
- Tests game selection
- Verifies level progression
- Tests game completion
- Checks reward system

### 3. Challenge System
- Tests daily challenges
- Tests weekly challenges
- Verifies challenge completion
- Tests reward claiming

### 4. Settings and Accessibility
- Tests font size adjustment
- Tests dyslexia-friendly font
- Tests high contrast mode
- Tests TTS functionality

### 5. Progress Tracking
- Tests progress recording
- Tests analytics display
- Tests export functionality

### 6. Web-Specific Features
- Tests responsive design
- Tests keyboard input
- Tests web navigation
- Tests cross-platform compatibility

## Writing New Tests

### Adding a New Test

```dart
testWidgets('New feature test', (WidgetTester tester) async {
  // Set up
  app.main();
  await tester.pumpAndSettle();

  // Test steps
  await TestConfig.tapAndWait(tester, find.text('Button Text'));
  
  // Verify results
  TestConfig.expectTextPresent(tester, 'Expected Text');
});
```

### Test Best Practices

1. **Use TestConfig utilities** for common operations
2. **Wait for animations** after interactions
3. **Verify UI state** after each major step
4. **Test edge cases** and error conditions
5. **Use descriptive test names** that explain the scenario
6. **Group related tests** using `group()`

### Platform-Specific Testing

```dart
// Test for specific platform
if (Platform.isAndroid) {
  // Android-specific test
} else if (kIsWeb) {
  // Web-specific test
}
```

## Debugging Tests

### Common Issues

1. **Timing Issues**: Use `TestConfig.waitForAnimations()` after interactions
2. **Widget Not Found**: Check if widget is visible and not covered
3. **Animation Issues**: Wait for animations to complete before assertions
4. **Platform Differences**: Use platform-specific conditionals

### Debug Commands

```bash
# Run with verbose output
task test-debug

# Run specific test with debug
task test-specific -- tests/integration/app_test.dart --verbose

# Run in watch mode for development
task test-watch
```

## Continuous Integration

The integration tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Integration Tests
  run: task test-integration

- name: Run Web Tests
  run: task test-integration-web

- name: Run Android Tests
  run: task test-integration-android
```

## Performance Considerations

- Tests are optimized for speed while maintaining reliability
- Use appropriate timeouts for different operations
- Group related tests to minimize setup/teardown overhead
- Use `setUpAll()` for expensive operations

## Troubleshooting

### Test Failures

1. **Check test environment**: Ensure Docker is running
2. **Verify dependencies**: Run `task test-setup`
3. **Clean test artifacts**: Run `task test-clean`
4. **Check logs**: Use `task logs` for detailed output

### Common Solutions

```bash
# Reset test environment
task test-clean
task test-setup

# Rebuild test image
task build-test

# Run with fresh environment
task test-integration
```

## Contributing

When adding new features to the app:

1. **Add corresponding integration tests**
2. **Test on both Android and Web platforms**
3. **Include edge cases and error conditions**
4. **Update this README** with new test information
5. **Ensure all tests pass** before submitting

## Support

For issues with integration tests:
1. Check the test logs for detailed error messages
2. Verify the test environment is properly set up
3. Ensure all dependencies are installed
4. Check for platform-specific issues

## Test Reports

After running tests, you can generate reports:

```bash
# Generate test report
task test-report

# Generate coverage report
task test-coverage
```

Reports are generated in the `coverage/` directory and can be viewed in a web browser. 