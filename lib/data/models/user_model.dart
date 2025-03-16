class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final int gamesPlayed;
  final int gamesWon;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.gamesPlayed = 0,
    this.gamesWon = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
    };
  }
} 