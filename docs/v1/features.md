# Algebrini – Full Feature Plan

This document details all planned features for Algebrini, including core, advanced, and future enhancements. It is intended as a comprehensive roadmap for the project.

---

## 1. Multilingual & Localization *(ALG-0001, ALG-0002; Roadmap Phase 1; Checkup 1)*
- Full support for French and English interfaces
- Easy in-app language switching
- Modular localization system for adding new languages
- All UI, instructions, and game content translatable
- RTL (right-to-left) language support (future)

## 2. User & Account Management *(ALG-0003, ALG-0004, ALG-0005, ALG-0006; Roadmap Phase 1, 4; Checkup 2)*
- Child account creation (username, avatar, age)
- Secure authentication (email/password, device-based, or parent code)
- Parental/teacher accounts with dashboard access
- Parental consent and privacy compliance (COPPA/GDPR)
- Multiple child profiles per device/account
- Password reset and account recovery
- Anonymous play mode (limited features)

## 3. Gameplay & Content *(ALG-0007, ALG-0008, ALG-0009, ALG-0010, ALG-0011; Roadmap Phase 1, 3; Checkup 3)*
- **Extensible mini-game system:**
  - Plugin/registry architecture for adding new games without modifying core code
  - Each game implements a common interface and is registered dynamically
- Interactive mini-games for:
  - Recursive sequences (Fibonacci, arithmetic, geometric)
  - Simple equations and inequalities
  - Factorization and algebraic expressions
  - Linear and quadratic functions
  - Mathematical logic and reasoning
- **Level progression system:**
  - Each game features multiple levels, from easy to hard
  - Levels are unlocked as the player progresses
  - Unlock logic and per-level achievements
- Story-driven magical universe with characters and narrative
- Unlockable content (levels, characters, environments)
- Randomized puzzles for replayability
- Hints and help system within games
- In-game tutorials and onboarding

## 4. Rewards & Motivation *(ALG-0012, ALG-0013, ALG-0014; Roadmap Phase 3; Checkup 4)*
- Visual rewards (stars, badges, trophies)
- Achievements for milestones (e.g., streaks, perfect scores)
- Daily/weekly challenges
- Leaderboards (global, friends, class)
- Customizable avatars and items
- Progress bars and feedback animations

## 5. Progress Tracking & Analytics *(ALG-0015, ALG-0016, ALG-0017; Roadmap Phase 4; Checkup 5)*
- Save and resume progress across devices
- Detailed progress tracking per user (levels, scores, time spent)
- Analytics dashboard for parents/teachers (performance, strengths, weaknesses)
- Exportable progress reports (PDF/CSV)
- Notifications for parents/teachers (optional)

## 6. Social & Collaborative Features *(ALG-0018, ALG-0019, ALG-0020; Roadmap Phase 4; Checkup 6)*
- Class/group creation and management (for schools/teachers)
- Group leaderboards and challenges
- Safe friend system (parent/teacher approval)
- In-app messaging (predefined, safe phrases)
- Share achievements with parents/teachers

## 7. Accessibility & Inclusivity *(ALG-0021, ALG-0022, ALG-0023; Roadmap Phase 2; Checkup 7)*
- Text-to-speech for all instructions and content
- Adjustable font sizes and color schemes
- Colorblind-friendly mode
- Dyslexia-friendly font option
- Keyboard and screen reader support

## 8. Platform & Technical *(ALG-0024, ALG-0025, ALG-0026; Roadmap Phase 1, 4; Checkup 8)*
- Cross-platform support (Android, iOS, Web, Desktop)
- Offline mode for mobile devices
- Cloud sync for accounts and progress
- **Robust, abstracted data persistence/service layer:**
  - All user data, progress, and achievements are managed via a service layer
  - Supports both local (device) and cloud (remote) storage
  - Easily extendable for future analytics or reporting
- **Modular codebase for easy expansion:**
  - Clear separation of concerns for games, UI, data, and services
  - Plugin/registry system for games and content
- Secure data storage and privacy controls

## 9. UI/UX for Kids *(ALG-0027, ALG-0028; Roadmap Phase 2; Checkup 9)*
- Playful, child-centric design with bright colors, large buttons, and friendly fonts
- Avatars, mascots, and reward animations to engage children
- Simple, intuitive navigation and feedback
- Animations and sound effects for actions and achievements
- Accessibility for all children, including those with disabilities

## 10. Support & Feedback *(ALG-0029, ALG-0030; Roadmap Phase 4; Checkup 10)*
- In-app help and FAQ
- Bug reporting and feedback submission
- Contact support (email or in-app form)
- Update notifications and changelog

## 11. Monetization (Optional/Future) *(ALG-0031, ALG-0032; Roadmap Phase 5; Checkup 11)*
- Free core app with optional premium content
- In-app purchases (cosmetics, extra levels)
- Subscription for advanced analytics or teacher tools
- No ads in child experience

---

This feature plan is a living document and may evolve as the project progresses. For MVP features, see mvp-features.md. 