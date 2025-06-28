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

  group('SettingsScreen Font Size Accessibility', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Font size slider is present and updates preview', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      expect(find.text('Font Size'), findsOneWidget);
      expect(find.text('Preview: The quick brown fox jumps over the lazy dog.'), findsOneWidget);
      final previewFinder = find.text('Preview: The quick brown fox jumps over the lazy dog.');
      final initialPreview = tester.widget<Text>(previewFinder);
      final initialFontSize = initialPreview.style?.fontSize;
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      await tester.ensureVisible(sliderFinder);
      // Tap at 80% of the slider's width to increase the value
      final slider = tester.widget<Slider>(sliderFinder);
      final sliderCenter = tester.getCenter(sliderFinder);
      final sliderStart = tester.getTopLeft(sliderFinder);
      final sliderEnd = tester.getTopRight(sliderFinder);
      final tapPosition = Offset(
        sliderStart.dx + 0.8 * (sliderEnd.dx - sliderStart.dx),
        sliderCenter.dy,
      );
      await tester.tapAt(tapPosition);
      await tester.pumpAndSettle();
      final updatedPreview = tester.widget<Text>(previewFinder);
      final updatedFontSize = updatedPreview.style?.fontSize;
      expect(updatedFontSize, isNot(equals(initialFontSize)));
    });

    testWidgets('Font size persists after settings are saved and screen is rebuilt', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final sliderFinder = find.byType(Slider);
      await tester.ensureVisible(sliderFinder);
      final slider = tester.widget<Slider>(sliderFinder);
      final sliderCenter = tester.getCenter(sliderFinder);
      final sliderStart = tester.getTopLeft(sliderFinder);
      final sliderEnd = tester.getTopRight(sliderFinder);
      final tapPosition = Offset(
        sliderStart.dx + 0.8 * (sliderEnd.dx - sliderStart.dx),
        sliderCenter.dy,
      );
      await tester.tapAt(tapPosition);
      await tester.pumpAndSettle();
      final previewFinder = find.text('Preview: The quick brown fox jumps over the lazy dog.');
      final preview = tester.widget<Text>(previewFinder);
      final changedFontSize = preview.style?.fontSize;
      final saveButtonFinder = find.text('Save Settings');
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();
      // Rebuild to simulate app restart
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final previewAfter = tester.widget<Text>(previewFinder);
      expect(previewAfter.style?.fontSize, equals(changedFontSize));
    });

    testWidgets('Dyslexia-Friendly Font toggle is present and updates font', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      expect(find.text('Dyslexia-Friendly Font'), findsOneWidget);
      final switchFinder = find.descendant(
        of: find.ancestor(of: find.text('Dyslexia-Friendly Font'), matching: find.byType(Row)),
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

    testWidgets('Dyslexia-Friendly Font persists after settings are saved and screen is rebuilt', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final switchFinder = find.descendant(
        of: find.ancestor(of: find.text('Dyslexia-Friendly Font'), matching: find.byType(Row)),
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
      SharedPreferences.setMockInitialValues({'dyslexiaFont': true});
      await tester.pumpWidget(buildTestableSettingsScreen());
      await tester.pumpAndSettle();
      final Switch switchAfter = tester.widget(switchFinder);
      expect(switchAfter.value, isTrue);
    });
  });
} 