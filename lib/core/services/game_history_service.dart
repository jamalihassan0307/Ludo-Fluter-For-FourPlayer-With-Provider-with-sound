import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/game_state_model.dart';

class GameHistoryService {
  static Box<Map>? _gamesBox;

  static Future<void> init() async {
    if (_gamesBox != null) return;

    await Hive.initFlutter();
    _gamesBox = await Hive.openBox<Map>('games');
  }

  static Future<void> saveGame(GameStateModel game) async {
    await init();
    await _gamesBox?.put(game.id, game.toJson());
  }

  static GameStateModel? getGame(String id) {
    final data = _gamesBox?.get(id);
    if (data == null) return null;
    return GameStateModel.fromJson(Map<String, dynamic>.from(data));
  }

  static List<GameStateModel> getAllGames() {
    if (_gamesBox == null) return [];
    return _gamesBox!.values.map((json) => GameStateModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  static List<GameStateModel> getUnfinishedGames() {
    if (_gamesBox == null) return [];

    try {
      return _gamesBox!.values
          .map((json) => GameStateModel.fromJson(Map<String, dynamic>.from(json)))
          .where((game) => !game.isCompleted)
          .toList();
    } catch (e) {
      print('Error loading unfinished games: $e');
      return [];
    }
  }

  static Future<void> deleteGame(String id) async {
    await init();
    await _gamesBox?.delete(id);
  }
}
