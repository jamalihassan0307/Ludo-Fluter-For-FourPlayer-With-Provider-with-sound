import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 3)
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final int gamesPlayed;

  @HiveField(2)
  final int gamesWon;

  LeaderboardEntry({
    required this.userId,
    required this.gamesPlayed,
    required this.gamesWon,
  });

  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;
} 