part of 'game_state_model.dart';

class GameStateModelAdapter extends TypeAdapter<GameStateModel> {
  @override
  final int typeId = 0;

  @override
  GameStateModel read(BinaryReader reader) {
    return GameStateModel(
      id: reader.read(),
      createdAt: reader.read(),
      players: reader.read(),
      gameMode: reader.read(),
      isCompleted: reader.read(),
      winners: reader.read(),
      currentState: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GameStateModel obj) {
    writer.write(obj.id);
    writer.write(obj.createdAt);
    writer.write(obj.players);
    writer.write(obj.gameMode);
    writer.write(obj.isCompleted);
    writer.write(obj.winners);
    writer.write(obj.currentState);
  }
}

class PlayerStateAdapter extends TypeAdapter<PlayerState> {
  @override
  final int typeId = 1;

  @override
  PlayerState read(BinaryReader reader) {
    return PlayerState(
      id: reader.read(),
      name: reader.read(),
      type: reader.read(),
      isBot: reader.read(),
      pawnPositions: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, PlayerState obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.type);
    writer.write(obj.isBot);
    writer.write(obj.pawnPositions);
  }
} 