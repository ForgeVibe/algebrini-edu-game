import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:algebrini_edu_game/services/rewards_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Initial rewards are zero/empty', () async {
    expect(await RewardsService.getCoins(), 0);
    expect(await RewardsService.getStars(), 0);
    expect(await RewardsService.getBadges(), isEmpty);
  });

  test('Earning coins and stars persists', () async {
    await RewardsService.addCoins(3);
    await RewardsService.addStars(7);
    expect(await RewardsService.getCoins(), 3);
    expect(await RewardsService.getStars(), 7);
    await RewardsService.addCoins(2);
    expect(await RewardsService.getCoins(), 5);
  });

  test('Earning and persisting badges', () async {
    await RewardsService.addBadge('math_master');
    await RewardsService.addBadge('quick_thinker');
    expect(await RewardsService.getBadges(), containsAll(['math_master', 'quick_thinker']));
    // Duplicate badge should not be added
    await RewardsService.addBadge('math_master');
    expect(await RewardsService.getBadges(), contains('math_master'));
    expect(await RewardsService.getBadges().then((b) => b.length), 2);
  });

  test('Resetting rewards clears all', () async {
    await RewardsService.addCoins(10);
    await RewardsService.addStars(10);
    await RewardsService.addBadge('reset_test');
    await RewardsService.resetRewards();
    expect(await RewardsService.getCoins(), 0);
    expect(await RewardsService.getStars(), 0);
    expect(await RewardsService.getBadges(), isEmpty);
  });
} 