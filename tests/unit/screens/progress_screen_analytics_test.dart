import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/screens/progress_screen.dart';
import 'package:algebrini_edu_game/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:algebrini_edu_game/services/font_size_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget _wrapWithProviders(Widget child) {
  return ChangeNotifierProvider<FontSizeProvider>(
    create: (_) => FontSizeProvider(),
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AnalyticsService.clearEvents();
  });

  testWidgets('Progress screen shows empty analytics state', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ProgressScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No recent activity'), findsOneWidget);
  });

  testWidgets('Progress screen shows recent analytics events', (tester) async {
    await AnalyticsService.logEvent('test_event', details: {'foo': 'bar'});
    await tester.pumpWidget(_wrapWithProviders(const ProgressScreen()));
    await tester.pumpAndSettle();
    expect(find.text('test_event'), findsOneWidget);
    expect(find.textContaining('foo'), findsOneWidget);
  });

  testWidgets('Export buttons are present and trigger export', (tester) async {
    await tester.pumpWidget(_wrapWithProviders(const ProgressScreen()));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Export CSV'), findsOneWidget);
    expect(find.byTooltip('Export JSON'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Export CSV'));
    await tester.tap(find.byTooltip('Export CSV'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Export JSON'));
    await tester.tap(find.byTooltip('Export JSON'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsOneWidget);
  });
} 