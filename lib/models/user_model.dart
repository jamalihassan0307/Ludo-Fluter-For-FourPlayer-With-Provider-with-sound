import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final bool isGoogleSignIn;
  final DateTime createdAt;
  final DateTime lastLogin;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> settings;
  final List<String> friends;
  final List<String> activeGames;
  final List<String> gameHistory;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    required this.isGoogleSignIn,
    required this.createdAt,
    required this.lastLogin,
    required this.stats,
    required this.settings,
    required this.friends,
    required this.activeGames,
    required this.gameHistory,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      isGoogleSignIn: map['isGoogleSignIn'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      friends: List<String>.from(map['friends'] ?? []),
      activeGames: List<String>.from(map['activeGames'] ?? []),
      gameHistory: List<String>.from(map['gameHistory'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'isGoogleSignIn': isGoogleSignIn,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'stats': stats,
      'settings': settings,
      'friends': friends,
      'activeGames': activeGames,
      'gameHistory': gameHistory,
    };
  }
}
