# Momentum - Your Life as a Video Game

A Flutter application that gamifies your daily life, turning real-world activities into quests, achievements, and stats. Track your progress, earn XP, and unlock achievements as you complete daily tasks and build better habits.

## Features

- 🎮 **Gamified Experience**: Transform your daily activities into quests and earn XP
- 📋 **Daily Quests**: Create and complete quests across different categories (Focus, Health, Discipline, Side Quests)
- 🏆 **Achievements**: Unlock achievements as you reach milestones
- 📊 **Statistics**: Visualize your progress with charts and detailed stats
- 💾 **Local Storage**: All data is stored locally using SharedPreferences
- 🎨 **Modern UI**: Built with Material Design 3 and beautiful charts

## Screenshots

*Add screenshots of your app here*

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vawcom-technologies/momentum.git
cd momentum
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── game_state.dart
│   ├── quest.dart
│   ├── achievement.dart
│   └── user_stats.dart
├── providers/                # State management
│   └── game_provider.dart
├── screens/                  # UI screens
│   ├── dashboard_screen.dart
│   ├── quests_screen.dart
│   ├── stats_screen.dart
│   ├── achievements_screen.dart
│   ├── settings_screen.dart
│   └── onboarding_screen.dart
├── services/                 # Business logic
│   ├── game_service.dart
│   └── storage_service.dart
└── widgets/                  # Reusable widgets
    └── bottom_nav_bar.dart
```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data persistence
- **fl_chart**: Beautiful charts and graphs
- **intl**: Internationalization and date formatting

## Features in Detail

### Quest System
- Create daily quests with different types (Focus, Health, Discipline, Side)
- Track quest completion status
- Earn XP rewards for completed quests

### Achievement System
- Unlock achievements based on milestones
- Track achievement progress
- Visual feedback for unlocked achievements

### Statistics
- View detailed stats and progress charts
- Track XP over time
- Monitor quest completion rates

## Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is private and proprietary.

## Contact

For questions or support, please contact the development team.
