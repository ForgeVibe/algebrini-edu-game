# Analytics & Progress Tracking

## Overview
The analytics system logs key user events (game actions, settings changes, progress resets, etc.) locally for privacy. Users can view recent activity and export their data as CSV or JSON.

## Event Types
- `correct_answer`: User answered a question correctly (includes game type)
- `incorrect_answer`: User answered incorrectly (includes game type)
- `game_completed`: User completed a game (includes game type)
- `progress_reset`: User reset all progress
- (Planned: settings changes, login/logout, etc.)

## Data Storage & Privacy
- All analytics are stored locally using SharedPreferences.
- No data is sent externally.
- Users can clear or export their analytics at any time.

## Export
- Users can export analytics as CSV or JSON from the Progress screen.
- Exported data includes timestamp, event type, and details.

## UI
- Recent activity is shown in the Progress screen, with export buttons.

## Test Coverage
- Unit tests for logging, retrieving, exporting, and clearing events (`test/services/analytics_service_test.dart`).
- Widget tests for Progress screen planned. 