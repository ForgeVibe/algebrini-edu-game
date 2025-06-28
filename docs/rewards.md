# Rewards & Motivation System

## Overview
Algebrini features a rewards system to motivate and engage learners. Players earn coins for correct answers, stars for completing games, and badges for special achievements.

## Usage
- **Coins:**
  - Earned for each correct answer (+1 per correct answer).
  - Displayed on the Home and Profile screens.
- **Stars:**
  - Earned for each game completion (+5 per game).
  - Displayed on the Home and Profile screens.
- **Badges:**
  - Earned for special milestones (future: e.g., streaks, high scores).
  - Displayed as chips on the Profile screen.

## Persistence
- All rewards are stored in `SharedPreferences` and persist across app restarts.

## Technical Details
- Managed by `RewardsService`.
- Rewards are updated automatically when answering questions or completing games.
- The UI updates in real time to reflect earned rewards.

## Automated Testing
- Unit tests for earning, persisting, and resetting coins, stars, and badges.
- Widget tests for displaying rewards on Home and Profile screens.
- Tests are located in `test/services/rewards_service_test.dart` and run via the Taskfile (`task test`). 