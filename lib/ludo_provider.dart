// ignore_for_file: sdk_version_since

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ludo_flutter/ludo_player.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'constants.dart';

class LudoProvider extends ChangeNotifier {
  ///Flags to check if pawn is moving
  bool _isMoving = false;

  ///Flags to stop pawn once disposed
  bool _stopMoving = false;

  LudoGameState _gameState = LudoGameState.throwDice;

  ///Game state to check if the game is in throw dice state or pick pawn state
  LudoGameState get gameState => _gameState;

  LudoPlayerType currentTurn = LudoPlayerType.green;

  int _diceResult = 0;

  ///Dice result to check the dice result of the current turn
  int get diceResult {
    if (_diceResult < 1) {
      return 1;
    } else {
      if (_diceResult > 6) {
        return 6;
      } else {
        return _diceResult;
      }
    }
  }

  bool _diceStarted = false;
  bool get diceStarted => _diceStarted;

  LudoPlayer get currentPlayer {
    if (players.isEmpty) {
      // Initialize players if empty
      startGame();
    }

    try {
      return players.firstWhere((element) => element.type == currentTurn);
    } catch (e) {
      // If current turn player not found, return first player
      return players.first;
    }
  }

  ///Fill all players
  final List<LudoPlayer> players = [];

  ///Player win, we use `LudoPlayerType` to make it easier to check
  final List<LudoPlayerType> winners = [];

  LudoPlayer player(LudoPlayerType type) {
    try {
      return players.firstWhere((element) => element.type == type);
    } catch (e) {
      // If player not found, return green player as default
      return players.first;
    }
  }

  ///This method will check if the pawn can kill another pawn or not by checking the step of the pawn
  bool checkToKill(LudoPlayerType type, int index, int step, List<List<double>> path) {
    bool killSomeone = false;

    // Only check for players that are actually in the game
    for (var player in players) {
      if (player.type != type) {
        // Don't check current player's pawns
        for (int i = 0; i < player.pawns.length; i++) {
          var pawn = player.pawns[i];
          if (pawn.step > -1 &&
              !LudoPath.safeArea.map((e) => e.toString()).contains(player.path[pawn.step].toString())) {
            if (player.path[pawn.step].toString() == path[step - 1].toString()) {
              killSomeone = true;
              player.movePawn(i, -1);
              notifyListeners();
            }
          }
        }
      }
    }
    return killSomeone;
  }

  int _numberOfPlayers = 4;

  void startGame({int numberOfPlayers = 4}) {
    _numberOfPlayers = numberOfPlayers;
    winners.clear();
    players.clear();
    _gameState = LudoGameState.throwDice;
    _diceResult = 0;
    _consecutiveSixes = 0;
    _isMoving = false;
    _stopMoving = false;

    // Add players based on number selected
    players.add(LudoPlayer(LudoPlayerType.red));

    if (numberOfPlayers >= 2) {
      players.add(LudoPlayer(LudoPlayerType.yellow));
    }

    if (numberOfPlayers >= 3) {
      players.add(LudoPlayer(LudoPlayerType.green));
    }

    if (numberOfPlayers == 4) {
      players.add(LudoPlayer(LudoPlayerType.blue));
    }

    // Set current turn to the first player (red)
    currentTurn = LudoPlayerType.red;

    notifyListeners();
  }

  // Track dice rolls in current turn
  List<int> currentTurnDiceRolls = [];
  bool shouldShowDicePopup = false;
  
  // Track consecutive sixes
  int _consecutiveSixes = 0;
  
  // Add dice history list
  final List<int> diceHistory = [];
  
  // Flag to indicate if dice is active for current player
  bool get isDiceActive => _gameState == LudoGameState.throwDice;
  
  // Points tracking
  Map<LudoPlayerType, int> playerPoints = {
    LudoPlayerType.red: 0,
    LudoPlayerType.yellow: 0,
    LudoPlayerType.green: 0,
    LudoPlayerType.blue: 0,
  };

  ///This is the function that will be called to throw the dice
  void throwDice() async {
    if (_gameState != LudoGameState.throwDice) return;
    _diceStarted = true;
    notifyListeners();
    await Audio.rollDice();

    // Check if already win skip
    if (winners.contains(currentPlayer.type)) {
      nextTurn();
      return;
    }

    // Turn off highlight for all pawns
    currentPlayer.highlightAllPawns(false);

    await Future.delayed(const Duration(seconds: 1));
    _diceStarted = false;
    var random = Random();
    _diceResult = random.nextInt(6) + 1; // Random between 1-6
    
    // Add to dice history
    diceHistory.add(_diceResult);
    if (diceHistory.length > 10) {
      diceHistory.removeAt(0); // Keep only the last 10 rolls
    }
    
    // Add to current turn rolls
    currentTurnDiceRolls.add(_diceResult);
    
    notifyListeners();

    if (diceResult == 6) {
      _consecutiveSixes++;
      
      // Check for three consecutive sixes
      if (_consecutiveSixes == 3) {
        // Reset consecutive sixes counter
        _consecutiveSixes = 0;
        
        // Play sound for canceled turn
        await Audio.playKill();
        
        // Show message about losing turn due to 3 consecutive sixes
        shouldShowDicePopup = true;
        
        // Clear current turn rolls
        currentTurnDiceRolls.clear();
        
        // Move to next player's turn after a delay
        await Future.delayed(const Duration(seconds: 1));
        nextTurn();
        return;
      }
      
      // For a 6, roll again after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      _gameState = LudoGameState.throwDice;
      notifyListeners();
    } else {
      // Reset consecutive sixes counter for non-6 roll
      _consecutiveSixes = 0;
      
      // Show dice popup with all rolls
      if (currentTurnDiceRolls.length > 1) {
        shouldShowDicePopup = true;
      }
      
      // Check if all pawns are in home
      if (currentPlayer.pawns.every((p) => p.step == currentPlayer.path.length - 1)) {
        // All pawns are in home, automatically move to next player
        currentTurnDiceRolls.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        return nextTurn();
      }
      
      // All pawns are inside starting area and no 6 was rolled
      if (currentPlayer.pawnInsideCount == 4 && !currentTurnDiceRolls.contains(6)) {
        // Clear current turn rolls
        currentTurnDiceRolls.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        return nextTurn();
      } else {
        // Highlight pawns that can move
        if (currentTurnDiceRolls.contains(6)) {
          // If we rolled a 6 at any point, highlight pawns inside home
          currentPlayer.highlightInside();
        }
        
        // Also highlight pawns outside home
        currentPlayer.highlightOutside();
        
        _gameState = LudoGameState.pickPawn;
        notifyListeners();
      }
    }
  }

  ///Move pawn to next step and check if it can kill other pawn
  void move(LudoPlayerType type, int index, int step) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;

    currentPlayer.highlightAllPawns(false);
    var selectedPlayer = player(type);

    // Get the last non-6 dice roll or the last roll if all are 6
    int lastRoll = currentTurnDiceRolls.lastWhere((roll) => roll != 6, orElse: () => currentTurnDiceRolls.last);

    // If moving from home, use 1 step
    int moveSteps = selectedPlayer.pawns[index].step == -1 ? 1 : lastRoll;

    // Calculate the new step position
    int newStep = selectedPlayer.pawns[index].step == -1 ? 0 : selectedPlayer.pawns[index].step + moveSteps;

    // Check if this would exceed the home position
    if (newStep >= selectedPlayer.path.length) {
      // Can't move beyond home, need exact roll
      int stepsToHome = selectedPlayer.path.length - 1 - selectedPlayer.pawns[index].step;
      if (lastRoll != stepsToHome) {
        // Can't move this pawn, cancel move
        _isMoving = false;
        _gameState = LudoGameState.pickPawn;
        notifyListeners();
        return;
      }
      // Set to exact home position
      newStep = selectedPlayer.path.length - 1;
    }

    // Move the pawn
    for (int i = selectedPlayer.pawns[index].step + 1; i <= newStep; i++) {
      if (_stopMoving) break;
      selectedPlayer.movePawn(index, i);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // If a kill happened, give an extra turn
    if (checkToKill(type, index, newStep, selectedPlayer.path)) {
      _gameState = LudoGameState.throwDice;
      _isMoving = false;
      Audio.playKill();
      currentTurnDiceRolls.clear(); // Clear rolls after kill
      notifyListeners();
      return;
    }

    validateWin(type);

    // Clear current turn rolls after move
    currentTurnDiceRolls.clear();

    // If the last roll was 6, give another turn
    if (diceResult == 6) {
      _gameState = LudoGameState.throwDice;
      notifyListeners();
    } else {
      nextTurn();
      notifyListeners();
    }
    _isMoving = false;
  }

  ///Next turn will be called when the player finish the turn
  void nextTurn() {
    currentTurnDiceRolls.clear();
    shouldShowDicePopup = false;

    int currentIndex = players.indexWhere((p) => p.type == currentTurn);
    if (currentIndex == -1) currentIndex = 0; // Fallback to first player if not found
    currentIndex = (currentIndex + 1) % players.length;
    currentTurn = players[currentIndex].type;

    if (winners.contains(currentTurn)) return nextTurn();
    _gameState = LudoGameState.throwDice;
    notifyListeners();
  }

  ///This function will check if the pawn finish the game or not
  void validateWin(LudoPlayerType color) {
    if (winners.map((e) => e.name).contains(color.name)) return;

    // Check if all pawns are exactly in the home position
    if (player(color).pawns.map((e) => e.step).every((element) => element == player(color).path.length - 1)) {
      winners.add(color);
      notifyListeners();
    }

    // Adjust win condition based on number of players
    if (winners.length == _numberOfPlayers - 1) {
      _gameState = LudoGameState.finish;
    }
  }

  // Check for blockades (2 pawns of same color on one square)
  bool isBlockade(List<double> position, LudoPlayerType type) {
    try {
      var currentPlayer = player(type);
      int pawnsAtPosition = currentPlayer.pawns
          .where((p) => p.step > -1 && currentPlayer.path[p.step].toString() == position.toString())
          .length;
      return pawnsAtPosition >= 2;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _stopMoving = true;
    super.dispose();
  }

  static LudoProvider read(BuildContext context) => context.read();

  // Add a method for testing with predefined dice rolls
  List<int> testRolls = [6, 6, 1, 6, 3, 4, 5, 6, 2]; // Example test rolls
  int testRollIndex = 0;

  void useTestRoll(bool useTest) {
    if (useTest) {
      // Override the dice roll with test values
      _diceResult = testRolls[testRollIndex % testRolls.length];
      testRollIndex++;
    }
    notifyListeners();
  }

  // Helper method to show message about 3 consecutive sixes
  void _showThreeSixesMessage() {
    // This would be implemented to show a message to the user
    print("Three consecutive sixes! Turn canceled.");
  }

  // Method to move pawn with specific dice roll
  void moveWithDiceRoll(LudoPlayerType type, int index, int diceRoll) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;

    currentPlayer.highlightAllPawns(false);
    var selectedPlayer = player(type);
    
    // Remove the used dice roll from the list
    currentTurnDiceRolls.remove(diceRoll);
    
    // If moving from home, use 1 step (requires a 6)
    int moveSteps = selectedPlayer.pawns[index].step == -1 ? 1 : diceRoll;
    
    // Calculate the new step position
    int newStep = selectedPlayer.pawns[index].step == -1 ? 0 : selectedPlayer.pawns[index].step + moveSteps;
    
    // Check if this would exceed the home position
    if (newStep >= selectedPlayer.path.length) {
      // Can't move beyond home, need exact roll
      int stepsToHome = selectedPlayer.path.length - 1 - selectedPlayer.pawns[index].step;
      if (diceRoll != stepsToHome) {
        // Can't move this pawn, cancel move
        _isMoving = false;
        _gameState = LudoGameState.pickPawn;
        notifyListeners();
        return;
      }
      // Set to exact home position
      newStep = selectedPlayer.path.length - 1;
    }
    
    // Move the pawn
    for (int i = selectedPlayer.pawns[index].step + 1; i <= newStep; i++) {
      if (_stopMoving) break;
      selectedPlayer.movePawn(index, i);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // If a kill happened, give an extra turn
    if (checkToKill(type, index, newStep, selectedPlayer.path)) {
      _gameState = LudoGameState.throwDice;
      _isMoving = false;
      await Audio.playKill();
      notifyListeners();
      return;
    }

    validateWin(type);

    // Check if there are more dice rolls to use
    if (currentTurnDiceRolls.isNotEmpty) {
      // Still have dice rolls to use
      _gameState = LudoGameState.pickPawn;
      
      // Highlight pawns that can move with remaining dice
      currentPlayer.highlightAllPawns(false);
      if (currentTurnDiceRolls.contains(6)) {
        currentPlayer.highlightInside();
      }
      currentPlayer.highlightOutside();
      
      // Show popup with remaining dice
      shouldShowDicePopup = true;
    } else {
      // No more dice rolls, end turn
      nextTurn();
    }
    
    _isMoving = false;
    notifyListeners();
  }
}
