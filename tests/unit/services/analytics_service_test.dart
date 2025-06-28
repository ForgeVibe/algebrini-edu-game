import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:algebrini_edu_game/services/analytics_service.dart';

dynamic _parseCSV(String csv) {
  final lines = csv.split('\n');
  final headers = lines.first.split(',');
  return lines.skip(1).map((line) {
    final values = line.split(',');
    return Map.fromIterables(headers, values);
  }).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AnalyticsService.clearEvents();
  });

  test('Initial analytics events are empty', () async {
    expect(await AnalyticsService.getEvents(), isEmpty);
  });

  test('Logging and retrieving events', () async {
    await AnalyticsService.logEvent('test_event', details: {'foo': 'bar'});
    final events = await AnalyticsService.getEvents();
    expect(events.length, 1);
    expect(events.first['type'], 'test_event');
    expect(events.first['details']['foo'], 'bar');
  });

  test('Export as CSV and JSON', () async {
    await AnalyticsService.logEvent('event1', details: {'a': 1});
    await AnalyticsService.logEvent('event2', details: {'b': 2});
    final csv = await AnalyticsService.exportAsCSV();
    final json = await AnalyticsService.exportAsJSON();
    expect(csv, contains('event1'));
    expect(csv, contains('event2'));
    expect(json, contains('event1'));
    expect(json, contains('event2'));
    final csvParsed = _parseCSV(csv);
    expect(csvParsed.length, 2);
  });

  test('Clearing events removes all analytics', () async {
    await AnalyticsService.logEvent('event1');
    await AnalyticsService.clearEvents();
    expect(await AnalyticsService.getEvents(), isEmpty);
  });
} 