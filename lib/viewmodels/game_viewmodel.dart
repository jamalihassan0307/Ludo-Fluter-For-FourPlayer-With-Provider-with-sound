import 'package:flutter/material.dart';
import '../data/repositories/game_repository.dart';
import '../data/models/game_model.dart';

class GameViewModel extends ChangeNotifier {
  final GameRepository _gameRepository = GameRepository();
  GameModel? _currentGame;
  bool _isLoading = false;

  GameModel? get currentGame => _currentGame;
  bool get isLoading => _isLoading;

  Future<void> createGame(String hostId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentGame = await _gameRepository.createGame(hostId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGame(String gameId, String playerId) async {
    await _gameRepository.joinGame(gameId, playerId);
  }

  void watchGame(String gameId) {
    _gameRepository.watchGame(gameId).listen((game) {
      _currentGame = game;
      notifyListeners();
    });
  }
} 