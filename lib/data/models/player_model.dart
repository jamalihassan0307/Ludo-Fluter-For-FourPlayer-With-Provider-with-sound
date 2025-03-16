import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

enum PlayerType { green, yellow, blue, red }

class PlayerModel {
  final String id;
  final String name;
  final PlayerType type;
  final int position;
  final bool isBot;
  final List<int> pawns = [0, 0, 0, 0]; // Initialize 4 pawns at position 0

  PlayerModel({
    required this.id,
    required this.name,
    required this.type,
    this.position = -1,
    this.isBot = false,
  });

  Color get color {
    switch (type) {
      case PlayerType.green:
        return ColorConstants.green;
      case PlayerType.yellow:
        return ColorConstants.yellow;
      case PlayerType.blue:
        return ColorConstants.blue;
      case PlayerType.red:
        return ColorConstants.red;
    }
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: PlayerType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PlayerType.green,
      ),
      position: json['position'] ?? -1,
      isBot: json['isBot'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'position': position,
      'isBot': isBot,
    };
  }
} 