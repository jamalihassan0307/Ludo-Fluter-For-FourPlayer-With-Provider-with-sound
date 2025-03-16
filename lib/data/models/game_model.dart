import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String hostId;
  final List<String> players;
  final String gameStatus;
  final Timestamp createdAt;
  final Map<String, dynamic> gameData;

  GameModel({
    required this.id,
    required this.hostId,
    required this.players,
    required this.gameStatus,
    required this.createdAt,
    required this.gameData,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      hostId: json['hostId'] ?? '',
      players: List<String>.from(json['players'] ?? []),
      gameStatus: json['gameStatus'] ?? 'waiting',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      gameData: json['gameData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'players': players,
      'gameStatus': gameStatus,
      'createdAt': createdAt,
      'gameData': gameData,
    };
  }
} 