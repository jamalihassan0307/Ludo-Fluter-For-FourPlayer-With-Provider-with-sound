class OfflineUser {
  final String email;
  final String password;
  final String name;
  final String? photoURL;
  final Map<String, dynamic> stats;

  OfflineUser({
    required this.email,
    required this.password,
    required this.name,
    this.photoURL,
    Map<String, dynamic>? stats,
  }) : stats = stats ?? {'gamesPlayed': 0, 'gamesWon': 0};

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'photoURL': photoURL,
      'stats': stats,
    };
  }

  factory OfflineUser.fromJson(Map<String, dynamic> json) {
    return OfflineUser(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      photoURL: json['photoURL'],
      stats: json['stats'] ?? {'gamesPlayed': 0, 'gamesWon': 0},
    );
  }
} 