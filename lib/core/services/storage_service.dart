import 'package:hive_flutter/hive_flutter.dart';
import 'package:ludo_flutter/data/models/game_state_model.dart';
import 'package:ludo_flutter/data/models/user_model.dart';
// import '../models/user_model.dart';

class StorageService {
  static late Box _settingsBox;
  static late Box<UserModel> _userBox;
  static late Box _gameStateBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(GameStateModelAdapter());
    Hive.registerAdapter(PlayerStateAdapter());

    // Open boxes
    _settingsBox = await Hive.openBox('settings');
    _userBox = await Hive.openBox<UserModel>('user');
    _gameStateBox = await Hive.openBox('gameState');
  }

  static Box getSettingsBox() => _settingsBox;
  static Box<UserModel> getUserBox() => _userBox;
  static Box getGameStateBox() => _gameStateBox;

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

  static Future<void> saveGameState(Map<String, dynamic> gameState) async {
    final box = getGameStateBox();
    await box.put('currentGame', gameState);
  }

  static Map<String, dynamic>? getGameState() {
    final box = getGameStateBox();
    return box.get('currentGame');
  }

  static Future<void> clearGameState() async {
    final box = getGameStateBox();
    await box.delete('currentGame');
  }
} 