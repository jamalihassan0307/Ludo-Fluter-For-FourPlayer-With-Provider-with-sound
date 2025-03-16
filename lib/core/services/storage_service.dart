import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class StorageService {
  static Future<void> init() async {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Register Hive Adapters here
    // await Hive.registerAdapter(YourModelAdapter());
    
    // Open Hive boxes
    await Hive.openBox('gameState');
    await Hive.openBox('settings');
  }

  static Box getGameStateBox() {
    return Hive.box('gameState');
  }

  static Box getSettingsBox() {
    return Hive.box('settings');
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