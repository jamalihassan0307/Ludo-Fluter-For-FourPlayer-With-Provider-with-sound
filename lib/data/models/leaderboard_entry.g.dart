part of 'leaderboard_entry.dart';

class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = 3;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    return LeaderboardEntry(
      userId: reader.read(),
      gamesPlayed: reader.read(),
      gamesWon: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer.write(obj.userId);
    writer.write(obj.gamesPlayed);
    writer.write(obj.gamesWon);
  }
} 