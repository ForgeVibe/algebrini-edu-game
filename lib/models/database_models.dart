import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'database_models.g.dart';

// Enums matching database schema
enum DifficultyLevel { easy, medium, hard, expert, master }
enum ChallengeType { daily, weekly, special }
enum UserRole { student, teacher, admin }

// Base model with common fields
abstract class BaseModel {
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  BaseModel({
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
}

@JsonSerializable()
class Game extends BaseModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int difficultyLevels;

  Game({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.difficultyLevels,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);
}

@JsonSerializable()
class Level extends BaseModel {
  final String id;
  final String gameId;
  final int levelNumber;
  final DifficultyLevel difficulty;
  final Map<String, dynamic>? requirements;

  Level({
    required this.id,
    required this.gameId,
    required this.levelNumber,
    required this.difficulty,
    this.requirements,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);
}

@JsonSerializable()
class Challenge extends BaseModel {
  final String id;
  final String levelId;
  final String question;
  final String answer;
  final String? hint;
  final String? explanation;
  final Map<String, dynamic>? metadata;
  final int difficultyScore;

  Challenge({
    required this.id,
    required this.levelId,
    required this.question,
    required this.answer,
    this.hint,
    this.explanation,
    this.metadata,
    required this.difficultyScore,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}

@JsonSerializable()
class Chapter extends BaseModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final Map<String, dynamic>? requirements;
  final String? realmId;
  final List<String> games;
  final List<int> levels;
  final String? storyCutsceneId;
  final Map<String, dynamic>? rewards;
  final int orderIndex;

  Chapter({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.requirements,
    this.realmId,
    required this.games,
    required this.levels,
    this.storyCutsceneId,
    this.rewards,
    required this.orderIndex,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterToJson(this);
}

@JsonSerializable()
class Realm extends BaseModel {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final String? background;

  Realm({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.background,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Realm.fromJson(Map<String, dynamic> json) => _$RealmFromJson(json);
  Map<String, dynamic> toJson() => _$RealmToJson(this);
}

@JsonSerializable()
class Achievement extends BaseModel {
  final String id;
  final String title;
  final String? description;
  final String? icon;
  final String? color;
  final Map<String, dynamic>? requirements;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.color,
    this.requirements,
    required this.points,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

@JsonSerializable()
class Avatar extends BaseModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final Map<String, dynamic>? unlockRequirements;

  Avatar({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.unlockRequirements,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarToJson(this);
}

@JsonSerializable()
class User extends BaseModel {
  final String id;
  final String username;
  final String email;
  final String? passwordHash;
  final UserRole role;
  final String? avatarId;
  final Map<String, dynamic> preferences;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    required this.role,
    this.avatarId,
    required this.preferences,
    this.lastLogin,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserProgress extends BaseModel {
  final String id;
  final String userId;
  final String gameId;
  final String levelId;
  final int score;
  final bool completed;
  final int? timeSeconds;
  final int attempts;
  final DateTime? completedAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.levelId,
    required this.score,
    required this.completed,
    this.timeSeconds,
    required this.attempts,
    this.completedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserProgressToJson(this);
}

// JSON converters for enums
class DifficultyLevelConverter implements JsonConverter<DifficultyLevel, String> {
  const DifficultyLevelConverter();

  @override
  DifficultyLevel fromJson(String json) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => DifficultyLevel.easy,
    );
  }

  @override
  String toJson(DifficultyLevel object) => object.name;
}

class ChallengeTypeConverter implements JsonConverter<ChallengeType, String> {
  const ChallengeTypeConverter();

  @override
  ChallengeType fromJson(String json) {
    return ChallengeType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ChallengeType.daily,
    );
  }

  @override
  String toJson(ChallengeType object) => object.name;
}

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    return UserRole.values.firstWhere(
      (e) => e.name == json,
      orElse: () => UserRole.student,
    );
  }

  @override
  String toJson(UserRole object) => object.name;
} 