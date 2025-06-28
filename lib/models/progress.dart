class Progress {
  List<int> completedLevels;
  Map<String, int> scores;
  List<String> achievements;

  Progress({
    required this.completedLevels,
    required this.scores,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => {
        'completedLevels': completedLevels,
        'scores': scores,
        'achievements': achievements,
      };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        completedLevels: List<int>.from(json['completedLevels'] ?? []),
        scores: Map<String, int>.from(json['scores'] ?? {}),
        achievements: List<String>.from(json['achievements'] ?? []),
      );
}
