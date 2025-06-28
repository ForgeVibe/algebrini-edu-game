class Profile {
  String username;
  int avatarIndex;

  Profile({required this.username, required this.avatarIndex});

  Map<String, dynamic> toJson() => {
        'username': username,
        'avatarIndex': avatarIndex,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        username: json['username'] as String,
        avatarIndex: json['avatarIndex'] as int,
      );
}
