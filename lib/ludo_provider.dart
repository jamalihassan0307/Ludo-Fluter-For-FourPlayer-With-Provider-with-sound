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
      startGame(numberOfPlayers: 4);
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
    if (step < 0) return false; // Can't kill if pawn is not on the board yet

    // Get the current position
    List<double> position = path[step];

    // Check if any other player's pawn is at this position
    for (var player in players) {
      if (player.type != type) {
        for (var i = 0; i < player.pawns.length; i++) {
          // Skip pawns that are not on the board or in safe zones
          if (player.pawns[i].step < 0 || isSafeZone(player.path[player.pawns[i].step])) {
            continue;
          }

          // Check if position matches
          if (player.pawns[i].step >= 0 &&
              player.pawns[i].step < player.path.length &&
              player.path[player.pawns[i].step].toString() == position.toString()) {
            // Kill the pawn
            player.movePawn(i, -1);
            return true;
          }
        }
      }
    }
    return false;
  }

  // Add a helper method to check if a position is in a safe zone
  bool isSafeZone(List<double> position) {
    // Define safe zone positions
    List<String> safeZones = [
      // Starting positions for each color (just after home)
      "[40.0, 280.0]", // Green start
      "[200.0, 40.0]", // Yellow start
      "[280.0, 200.0]", // Blue start
      "[120.0, 280.0]", // Red start

      // Star positions on the board
      "[40.0, 200.0]",
      "[80.0, 120.0]",
      "[120.0, 40.0]",
      "[200.0, 80.0]",
      "[280.0, 120.0]",
      "[240.0, 200.0]",
      "[200.0, 280.0]",
      "[120.0, 240.0]",

      // Home path positions (last 6 steps before home)
      // Green home path
      "[80.0, 160.0]",
      "[80.0, 180.0]",
      "[80.0, 200.0]",
      "[80.0, 220.0]",
      "[80.0, 240.0]",
      "[80.0, 260.0]",

      // Yellow home path
      "[160.0, 80.0]",
      "[180.0, 80.0]",
      "[200.0, 80.0]",
      "[220.0, 80.0]",
      "[240.0, 80.0]",
      "[260.0, 80.0]",

      // Blue home path
      "[240.0, 160.0]",
      "[240.0, 180.0]",
      "[240.0, 200.0]",
      "[240.0, 220.0]",
      "[240.0, 240.0]",
      "[240.0, 260.0]",

      // Red home path
      "[160.0, 240.0]",
      "[180.0, 240.0]",
      "[200.0, 240.0]",
      "[220.0, 240.0]",
      "[240.0, 240.0]",
      "[260.0, 240.0]",
    ];

    return safeZones.contains(position.toString());
  }

  int _numberOfPlayers = 4;

  void startGame({required int numberOfPlayers}) {
    players.clear();
    winners.clear();
    currentTurnDiceRolls.clear();
    _gameState = LudoGameState.throwDice;
    _diceStarted = false;
    _diceResult = 1;
    shouldShowDicePopup = false;

    // Initialize players in the specified order
    if (numberOfPlayers == 4) {
      // For 4 players: Red -> Green -> Yellow -> Blue
      players.add(LudoPlayer(LudoPlayerType.red));    // Bottom Left
      players.add(LudoPlayer(LudoPlayerType.green));  // Top Left
      players.add(LudoPlayer(LudoPlayerType.yellow)); // Top Right
      players.add(LudoPlayer(LudoPlayerType.blue));   // Bottom Right
    } else if (numberOfPlayers == 3) {
      // For 3 players: Red -> Yellow -> Blue
      players.add(LudoPlayer(LudoPlayerType.red));    // Bottom Left
      players.add(LudoPlayer(LudoPlayerType.yellow)); // Top Right
      players.add(LudoPlayer(LudoPlayerType.blue));   // Bottom Right
    } else {
      // For 2 players: Red -> Yellow
      players.add(LudoPlayer(LudoPlayerType.red));    // Bottom Left
      players.add(LudoPlayer(LudoPlayerType.yellow)); // Top Right
    }

    currentTurn = players.first.type;
    notifyListeners();
  }

  // Track dice rolls in current turn
  List<int> currentTurnDiceRolls = [];
  bool _shouldShowDicePopup = false;
  bool get shouldShowDicePopup => _shouldShowDicePopup;
  set shouldShowDicePopup(bool value) {
    _shouldShowDicePopup = value;
    notifyListeners();
  }

  // Track consecutive sixes
  int _consecutiveSixes = 0;

  // Add a public getter for _consecutiveSixes
  int get consecutiveSixes => _consecutiveSixes;

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

    // Reduce delay for faster gameplay
    await Future.delayed(const Duration(milliseconds: 300));
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

    // Check for three consecutive sixes
    if (_diceResult == 6) {
      _consecutiveSixes++;
      if (_consecutiveSixes >= 3) {
        // Three consecutive sixes, cancel turn
        _consecutiveSixes = 0;
        currentTurnDiceRolls.clear();
        shouldShowDicePopup = true;

        // Move to next player's turn after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        nextTurn();
        return;
      }

      // For a 6, roll again after a short delay
      await Future.delayed(const Duration(milliseconds: 300));
      _gameState = LudoGameState.throwDice;
      notifyListeners();
      return;
    }

    // Reset consecutive sixes counter
    _consecutiveSixes = 0;

    // Check if all pawns are in home
    if (currentPlayer.pawns.every((p) => p.step == currentPlayer.path.length - 1)) {
      // All pawns are in home, automatically move to next player
      currentTurnDiceRolls.clear();
      await Future.delayed(const Duration(milliseconds: 300));
      return nextTurn();
    }

    // All pawns are inside starting area and no 6 was rolled
    if (currentPlayer.pawnInsideCount == 4 && !currentTurnDiceRolls.contains(6)) {
      // Clear current turn rolls
      currentTurnDiceRolls.clear();
      await Future.delayed(const Duration(milliseconds: 300));
          return nextTurn();
        } else {
      // Highlight pawns that can move
      if (currentTurnDiceRolls.contains(6)) {
        // Also highlight pawns inside home
        currentPlayer.highlightInside();
      }

      // Also highlight pawns outside home
      currentPlayer.highlightOutside();

      // Check if only one pawn can move, then move it automatically
      List<int> movablePawnIndices = [];
      for (int i = 0; i < currentPlayer.pawns.length; i++) {
        if (currentPlayer.pawns[i].highlight) {
          movablePawnIndices.add(i);
        }
      }

      if (movablePawnIndices.length == 1) {
        // Only one pawn can move, move it automatically
        int index = movablePawnIndices[0];
        move(currentPlayer.type, index, 0); // The actual step will be calculated in move()
            return;
      }

      _gameState = LudoGameState.pickPawn;
      notifyListeners();
    }
  }

  ///Move pawn to next step and check if it can kill other pawn
  Future<void> move(LudoPlayerType type, int index, int step) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;

    var selectedPlayer = player(type);

    // Calculate the actual step to move to
    int actualStep = step;
    if (selectedPlayer.pawns[index].step == -1) {
      // Moving out of home
      actualStep = 0;
    }

    // Animate the movement
    for (int i = selectedPlayer.pawns[index].step + 1; i <= actualStep; i++) {
      if (_stopMoving) break;
      selectedPlayer.movePawn(index, i);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Check if a kill happened
    bool killed = checkToKill(type, index, actualStep, selectedPlayer.path);

    // Check for win
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

      // If a kill happened, give an extra turn
      if (killed) {
      _gameState = LudoGameState.throwDice;
      _isMoving = false;
        await Audio.playKill();
      notifyListeners();
      return;
    }

      // Check if any pawns can move with the remaining dice
      bool canMoveAny = false;
      for (int i = 0; i < currentPlayer.pawns.length; i++) {
        if (currentPlayer.pawns[i].highlight) {
          canMoveAny = true;
          break;
        }
      }

      if (!canMoveAny) {
        // No pawns can move with remaining dice, end turn
        currentTurnDiceRolls.clear();
        nextTurn();
      } else {
        // Show dice popup for remaining dice
        shouldShowDicePopup = true;
      }
    } else {
      // No more dice rolls, end turn
      nextTurn();
    }

    _isMoving = false;
    notifyListeners();
  }

  ///Next turn will be called when the player finish the turn
  void nextTurn() {
    if (winners.length == players.length - 1) {
      _gameState = LudoGameState.finish;
      notifyListeners();
      return;
    }

    // Find the next player in the specified order
    int currentIndex = players.indexWhere((player) => player.type == currentTurn);
    int nextIndex;

    // Keep trying next player until we find one that hasn't won yet
    do {
      nextIndex = (currentIndex + 1) % players.length;
      currentIndex = nextIndex;
    } while (winners.contains(players[nextIndex].type));

    currentTurn = players[nextIndex].type;
    currentTurnDiceRolls.clear();
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
  void moveWithDiceRoll(LudoPlayerType type, int index, int diceRoll) {
    // Remove the used dice roll from the list before moving
    currentTurnDiceRolls.remove(diceRoll);

    // Get the player
    var selectedPlayer = player(type);

    // If moving from home, use step 0
    if (selectedPlayer.pawns[index].step == -1) {
      if (diceRoll == 6) {
        move(type, index, 0);
      }
    } else {
      // Move forward
      move(type, index, selectedPlayer.pawns[index].step + diceRoll);
    }
  }
}
