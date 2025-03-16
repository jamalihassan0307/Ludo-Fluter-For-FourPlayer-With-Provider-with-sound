import 'package:hive_flutter/hive_flutter.dart';
import 'package:ludo_flutter/data/models/game_state_model.dart';
import 'package:ludo_flutter/data/models/user_model.dart';
import 'package:ludo_flutter/data/models/leaderboard_entry.dart';
// import '../models/user_model.dart';

class StorageService {
  static late Box _settingsBox;
  static late Box<UserModel> _userBox;
  static late Box<GameStateModel> _gameStateBox;
  static late Box<LeaderboardEntry> _leaderboardBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(GameStateModelAdapter());
    Hive.registerAdapter(PlayerStateAdapter());
    Hive.registerAdapter(LeaderboardEntryAdapter());

    // Open boxes
    _settingsBox = await Hive.openBox('settings');
    _userBox = await Hive.openBox<UserModel>('user');
    _gameStateBox = await Hive.openBox<GameStateModel>('gameState');
    _leaderboardBox = await Hive.openBox<LeaderboardEntry>('leaderboard');
  }

  static Box getSettingsBox() => _settingsBox;
  static Box<UserModel> getUserBox() => _userBox;
  static Box<GameStateModel> getGameStateBox() => _gameStateBox;

  static Future<void> saveUser(UserModel user) async {
    await _userBox.put('currentUser', user);
  }

  static UserModel? getCurrentUser() {
    return _userBox.get('currentUser');
  }

  static bool isUserLoggedIn() {
    return getCurrentUser() != null;
  }

  static Future<void> clearUser() async {
    await _userBox.clear();
  }

  static Future<void> saveGameState(GameStateModel gameState) async {
    await _gameStateBox.put('currentGame', gameState);
  }

  static GameStateModel? getGameState() {
    return _gameStateBox.get('currentGame');
  }

  static Future<void> clearGameState() async {
    final box = getGameStateBox();
    await box.delete('currentGame');
  }

  static Future<void> updateLeaderboard(String userId, bool won) async {
    var entry = _leaderboardBox.get(userId) ?? LeaderboardEntry(userId: userId, gamesPlayed: 0, gamesWon: 0);

    entry = LeaderboardEntry(
      userId: userId,
      gamesPlayed: entry.gamesPlayed + 1,
      gamesWon: entry.gamesWon + (won ? 1 : 0),
    );

    await _leaderboardBox.put(userId, entry);
  }

  static List<LeaderboardEntry> getLeaderboard() {
    return _leaderboardBox.values.toList()..sort((a, b) => b.gamesWon.compareTo(a.gamesWon));
  }
}
