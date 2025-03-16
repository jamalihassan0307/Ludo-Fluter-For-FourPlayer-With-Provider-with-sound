import 'package:hive/hive.dart';

part 'game_state_model.g.dart';

@HiveType(typeId: 0)
class GameStateModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final List<PlayerState> players;

  @HiveField(3)
  final String gameMode; // 'computer', 'local'

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final List<String> winners;

  @HiveField(6)
  final Map<String, dynamic> currentState;

  GameStateModel({
    required this.id,
    required this.createdAt,
    required this.players,
    required this.gameMode,
    this.isCompleted = false,
    this.winners = const [],
    required this.currentState,
  });

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      players: (json['players'] as List).map((p) => PlayerState.fromJson(p)).toList(),
      gameMode: json['gameMode'],
      isCompleted: json['isCompleted'] ?? false,
      winners: List<String>.from(json['winners'] ?? []),
      currentState: json['currentState'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'players': players.map((p) => p.toJson()).toList(),
      'gameMode': gameMode,
      'isCompleted': isCompleted,
      'winners': winners,
      'currentState': currentState,
    };
  }
}

@HiveType(typeId: 1)
class PlayerState {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final bool isBot;

  @HiveField(4)
  final List<int> pawnPositions;

  PlayerState({
    required this.id,
    required this.name,
    required this.type,
    this.isBot = false,
    required this.pawnPositions,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isBot: json['isBot'] ?? false,
      pawnPositions: List<int>.from(json['pawnPositions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isBot': isBot,
      'pawnPositions': pawnPositions,
    };
  }
}
