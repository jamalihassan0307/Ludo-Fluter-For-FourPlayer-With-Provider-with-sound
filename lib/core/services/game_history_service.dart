import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/game_state_model.dart';

class GameHistoryService {
  static Box<GameStateModel>? _gamesBox;

  static Future<void> init() async {
    if (_gamesBox != null) return;

    await Hive.initFlutter();
    Hive.registerAdapter(GameStateModelAdapter());
    Hive.registerAdapter(PlayerStateAdapter());
    _gamesBox = await Hive.openBox<GameStateModel>('games');
  }

  static Future<void> saveGame(GameStateModel game) async {
    await init();
    await _gamesBox?.put(game.id, game);
  }

  static GameStateModel? getGame(String id) {
    return _gamesBox?.get(id);
  }

  static List<GameStateModel> getAllGames() {
    if (_gamesBox == null) return [];
    return _gamesBox!.values.toList();
  }

  static List<GameStateModel> getUnfinishedGames() {
    if (_gamesBox == null) return [];
    return _gamesBox!.values.where((game) => !game.isCompleted).toList();
  }

  static Future<void> deleteGame(String id) async {
    await init();
    await _gamesBox?.delete(id);
  }
}
