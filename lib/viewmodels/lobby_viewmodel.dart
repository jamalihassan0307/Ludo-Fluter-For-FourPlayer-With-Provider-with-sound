import 'package:flutter/material.dart';
import '../core/services/navigation_service.dart';
import '../core/constants/app_constants.dart';
import '../data/models/player_model.dart';
import '../core/services/storage_service.dart';
import '../data/models/game_state_model.dart';

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

    // Add first player (Green)
    addPlayer(PlayerModel(
      id: '1',
      name: 'Player 1',
      type: PlayerType.green,
    ));

    // If computer mode, add AI player (Red)
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
    StorageService.saveGameState(GameStateModel(
      id: DateTime.now().toString(),
      createdAt: DateTime.now(),
      players: _players
          .map((p) => PlayerState(
                id: p.id,
                name: p.name,
                type: p.type.toString(),
                pawnPositions: [], // Initialize empty since game hasn't started
              ))
          .toList(),
      gameMode: _gameMode,
      isCompleted: false,
      currentState: {
        'currentTurn': PlayerType.green.toString(),
        'gameState': 'initial',
        'diceResult': 0,
      },
    ));

    NavigationService.navigateTo(AppConstants.gameRoute);
  }

  bool canAddPlayer() {
    return _players.length < 2; // Limit to 2 players
  }
}
