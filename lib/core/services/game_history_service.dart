import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/game_state_model.dart';

class GameHistoryService {
  static late Box<GameStateModel> _gamesBox;

  static Future<void> init() async {
    Hive.registerAdapter(GameStateModelAdapter());
    Hive.registerAdapter(PlayerStateAdapter());
    _gamesBox = await Hive.openBox<GameStateModel>('games');
  }

  static Future<void> saveGame(GameStateModel game) async {
    await _gamesBox.put(game.id, game);
  }

  static GameStateModel? getGame(String id) {
    return _gamesBox.get(id);
  }

  static List<GameStateModel> getAllGames() {
    return _gamesBox.values.toList();
  }

  static List<GameStateModel> getUnfinishedGames() {
    return _gamesBox.values.where((game) => !game.isCompleted).toList();
  }

  static Future<void> deleteGame(String id) async {
    await _gamesBox.delete(id);
  }
} 