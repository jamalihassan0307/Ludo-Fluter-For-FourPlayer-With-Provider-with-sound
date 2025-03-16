import 'package:flutter/material.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../data/models/player_model.dart';
import '../core/services/storage_service.dart';

class LobbyViewModel extends ChangeNotifier {
  final List<PlayerModel> _players = [];
  bool _isLoading = false;
  String _gameMode = 'local'; // local, computer

  List<PlayerModel> get players => _players;
  bool get isLoading => _isLoading;
  bool get canStartGame => _players.length >= 2;

  LobbyViewModel() {
    _initializeLobby();
  }

  void _initializeLobby() {
    final settings = StorageService.getSettingsBox();
    _gameMode = settings.get('gameMode', defaultValue: 'local');
    
    // Add first player
    addPlayer(PlayerModel(
      id: '1',
      name: 'Player 1',
      type: PlayerType.green,
    ));

    // If computer mode, add AI player
    if (_gameMode == 'computer') {
      addPlayer(PlayerModel(
        id: 'ai',
        name: 'Computer',
        type: PlayerType.red,
        isBot: true,
      ));
    }
  }

  void addPlayer(PlayerModel player) {
    if (_players.length < 4) {
      _players.add(player);
      notifyListeners();
    }
  }

  void removePlayer(String playerId) {
    _players.removeWhere((player) => player.id == playerId);
    notifyListeners();
  }

  void startGame() {
    // Save current players to game state
    StorageService.saveGameState({
      'players': _players.map((p) => p.toJson()).toList(),
      'gameMode': _gameMode,
    });
    
    NavigationService.navigateTo(AppConstants.gameRoute);
  }
} 