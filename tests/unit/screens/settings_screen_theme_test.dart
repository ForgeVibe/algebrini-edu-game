import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:algebrini_edu_game/services/font_size_provider.dart';
import 'package:algebrini_edu_game/services/theme_provider.dart';

Widget buildTestableSettingsScreen() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
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
      home: Scaffold(body: SettingsScreen()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen High Contrast/Colorblind Mode', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('High Contrast/Colorblind Mode toggle is present and updates theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      expect(find.text('High Contrast/Colorblind Mode'), findsOneWidget);
      final switchFinder = find.descendant(
        of: find.ancestor(of: find.text('High Contrast/Colorblind Mode'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(switchFinder);
      final Switch initialSwitch = tester.widget(switchFinder);
      expect(initialSwitch.value, isFalse);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      final Switch updatedSwitch = tester.widget(switchFinder);
      expect(updatedSwitch.value, isTrue);
    });

    testWidgets('High Contrast/Colorblind Mode persists after settings are saved and screen is rebuilt', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final switchFinder = find.descendant(
        of: find.ancestor(of: find.text('High Contrast/Colorblind Mode'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      final saveButtonFinder = find.text('Save Settings');
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();
      // Rebuild to simulate app restart
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final Switch switchAfter = tester.widget(switchFinder);
      expect(switchAfter.value, isTrue);
    });
  });
} 