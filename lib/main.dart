import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/play_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/world_map_screen.dart';
import 'services/font_size_provider.dart';
import 'services/theme_provider.dart';
import 'services/game_data_service.dart';
import 'services/game_registry.dart';
import 'games/game_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if we're running in test mode
  final isTestMode = const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
  
  if (isTestMode) {
    // Skip shared_preferences initialization for tests
    runApp(AlgebriniApp(gameDataService: null));
  } else {
    // Initialize database service
    final gameDataService = GameDataService();
    await gameDataService.initialize();

    // Initialize game registry with database support
    GameRegistry().initializeWithDatabase(gameDataService);

    runApp(AlgebriniApp(gameDataService: gameDataService));
  }
}

class AlgebriniApp extends StatelessWidget {
  final GameDataService? gameDataService;

  const AlgebriniApp({super.key, this.gameDataService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        if (gameDataService != null)
          Provider<GameDataService>.value(value: gameDataService!),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final highContrast = themeProvider.highContrast;
          return MaterialApp(
            title: 'Algebrini',
            debugShowCheckedModeBanner: false,
            theme: highContrast
                ? ThemeData(
                    colorScheme: ColorScheme.highContrastDark(
                      primary: Colors.black,
                      secondary: Colors.yellow,
                      surface: Colors.white,
                      background: Colors.black,
                      error: Colors.red.shade900,
                    ),
                    useMaterial3: true,
                    fontFamily: 'Roboto',
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    scaffoldBackgroundColor: Colors.black,
                    textTheme: const TextTheme(
                      bodyLarge: TextStyle(color: Colors.yellow),
                      bodyMedium: TextStyle(color: Colors.yellow),
                      bodySmall: TextStyle(color: Colors.yellow),
                    ),
                  )
                : ThemeData(
                    colorScheme:
                        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                    fontFamily: 'Roboto',
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
              Locale('es'),
              Locale('de'),
            ],
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Global key to access this state from other widgets
  static final GlobalKey<_MainNavigationState> globalKey =
      GlobalKey<_MainNavigationState>();

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    PlayScreen(),
    WorldMapScreen(),
    ChallengesScreen(),
    ProgressScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      key: globalKey,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: loc.homeWelcome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.videogame_asset),
            label: loc.play,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: 'Story Mode',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: loc.progress,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: loc.profile,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: loc.settings,
          ),
        ],
      ),
    );
  }
}
