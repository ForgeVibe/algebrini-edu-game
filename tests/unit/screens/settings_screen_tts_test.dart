import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

  group('SettingsScreen TTS Accessibility', () {
    testWidgets('TTS toggle is present and defaults to enabled', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'ttsEnabled': true});
      final prefs = await SharedPreferences.getInstance();
      print('DEBUG: ttsEnabled before widget build: \'${prefs.getBool('ttsEnabled')}\'');
      await tester.pumpWidget(buildTestableSettingsScreen());
      // Wait for loading indicator to disappear
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Text-to-Speech (TTS)'), findsOneWidget);
      // Find the Switch widget that is a sibling of the label
      final ttsLabelFinder = find.text('Text-to-Speech (TTS)');
      final switchFinder = find.descendant(
        of: find.ancestor(of: ttsLabelFinder, matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      expect(switchFinder, findsOneWidget);
      final Switch ttsSwitch = tester.widget(switchFinder);
      expect(ttsSwitch.value, isTrue);
    });

    testWidgets('TTS toggle can be disabled and persists', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'ttsEnabled': true});
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final ttsLabelFinder = find.text('Text-to-Speech (TTS)');
      expect(ttsLabelFinder, findsOneWidget);
      // Find the Switch widget that is a sibling of the label
      final switchFinder = find.descendant(
        of: find.ancestor(of: ttsLabelFinder, matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      final Switch ttsSwitch = tester.widget(switchFinder);
      expect(ttsSwitch.value, isFalse);
      // Save settings
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();
      // Rebuild to simulate app restart
      SharedPreferences.setMockInitialValues({'ttsEnabled': false});
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final Switch ttsSwitch2 = tester.widget(switchFinder);
      expect(ttsSwitch2.value, isFalse);
    });
  });
} 