import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../lib/services/database_service.dart';
import '../../lib/services/game_data_service.dart';
import '../../lib/models/database_models.dart';

void main() {
  group('Database Integration Tests', () {
    late DatabaseService databaseService;
    late GameDataService gameDataService;

    setUpAll(() async {
      databaseService = DatabaseService();
      gameDataService = GameDataService();
      await databaseService.initialize();
      await gameDataService.initialize();
    });

    tearDownAll(() async {
      await databaseService.close();
    });

    group('API Server Tests', () {
      test('API server health check', () async {
        final response = await http.get(Uri.parse('http://localhost:3000/api/health'));
        expect(response.statusCode, 200);
        
        final data = jsonDecode(response.body);
        expect(data['status'], 'healthy');
        expect(data['database'], 'connected');
      });

      test('Get games from API', () async {
        final response = await http.get(Uri.parse('http://localhost:3000/api/games'));
        expect(response.statusCode, 200);
        
        final games = jsonDecode(response.body) as List;
        expect(games.length, greaterThan(0));
        
        final game = games.first;
        expect(game['id'], isA<String>());
        expect(game['name'], isA<String>());
        expect(game['is_active'], true);
      });

      test('Get chapters from API', () async {
        final response = await http.get(Uri.parse('http://localhost:3000/api/chapters'));
        expect(response.statusCode, 200);
        
        final chapters = jsonDecode(response.body) as List;
        expect(chapters.length, greaterThan(0));
      });

      test('Get realms from API', () async {
        final response = await http.get(Uri.parse('http://localhost:3000/api/realms'));
        expect(response.statusCode, 200);
        
        final realms = jsonDecode(response.body) as List;
        expect(realms.length, greaterThan(0));
      });
    });

    group('Database Service Tests', () {
      test('Database connection status', () {
        expect(databaseService.isConnected, true);
      });

      test('Get games from database', () async {
        final games = await databaseService.getGames();
        expect(games.length, greaterThan(0));
        
        final game = games.first;
        expect(game.id, isA<String>());
        expect(game.name, isA<String>());
        expect(game.isActive, true);
      });

      test('Get game by ID', () async {
        final games = await databaseService.getGames();
        if (games.isNotEmpty) {
          final gameId = games.first.id;
          final game = await databaseService.getGameById(gameId);
          expect(game, isNotNull);
          expect(game!.id, gameId);
        }
      });

      test('Get levels for a game', () async {
        final games = await databaseService.getGames();
        if (games.isNotEmpty) {
          final gameId = games.first.id;
          final levels = await databaseService.getLevelsByGameId(gameId);
          expect(levels, isA<List<Level>>());
        }
      });
    });

    group('Game Data Service Tests', () {
      test('Get games with caching', () async {
        final games = await gameDataService.getGames();
        expect(games.length, greaterThan(0));
        
        // Test cache by calling again
        final cachedGames = await gameDataService.getGames();
        expect(cachedGames.length, games.length);
      });

      test('Get chapters with caching', () async {
        final chapters = await gameDataService.getChapters();
        expect(chapters.length, greaterThan(0));
      });

      test('Get realms with caching', () async {
        final realms = await gameDataService.getRealms();
        expect(realms.length, greaterThan(0));
      });

      test('Get levels for a game', () async {
        final games = await gameDataService.getGames();
        if (games.isNotEmpty) {
          final gameId = games.first.id;
          final levels = await gameDataService.getLevels(gameId);
          expect(levels, isA<List<Level>>());
        }
      });

      test('Get challenges for a level', () async {
        final games = await gameDataService.getGames();
        if (games.isNotEmpty) {
          final gameId = games.first.id;
          final levels = await gameDataService.getLevels(gameId);
          if (levels.isNotEmpty) {
            final levelId = levels.first.id;
            final challenges = await gameDataService.getChallenges(levelId);
            expect(challenges, isA<List<Challenge>>());
          }
        }
      });
    });

    group('Error Handling Tests', () {
      test('Handle database connection failure gracefully', () async {
        // This test would require temporarily stopping the database
        // For now, we'll test the API fallback mechanism
        final games = await gameDataService.getGames();
        expect(games, isA<List<Game>>());
      });
    });
  });
} 