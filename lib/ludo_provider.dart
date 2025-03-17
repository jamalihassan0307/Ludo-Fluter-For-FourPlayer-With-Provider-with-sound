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

  // Add dice history list
  final List<int> diceHistory = [];

  ///Track consecutive sixes
  int _consecutiveSixes = 0;

  ///This is the function that will be called to throw the dice
  void throwDice() async {
    if (_gameState != LudoGameState.throwDice) return;
    _diceStarted = true;
    notifyListeners();
    Audio.rollDice();

    //Check if already win skip
    if (winners.contains(currentPlayer.type)) {
      nextTurn();
      return;
    }

    //Turn off highlight for all pawns
    currentPlayer.highlightAllPawns(false);

    Future.delayed(const Duration(seconds: 1)).then((value) {
      _diceStarted = false;
      var random = Random();
      _diceResult = random.nextBool() ? 6 : random.nextInt(6) + 1; //Random between 1 - 6

      // Add to dice history
      diceHistory.add(_diceResult);
      if (diceHistory.length > 10) {
        diceHistory.removeAt(0); // Keep only the last 10 rolls
      }

      notifyListeners();

      if (diceResult == 6) {
        _consecutiveSixes++;

        // Check for three consecutive sixes
        if (_consecutiveSixes == 3) {
          // Reset consecutive sixes counter
          _consecutiveSixes = 0;

          // Show message about losing turn due to 3 consecutive sixes
          _showThreeSixesMessage();

          // Move to next player's turn
          nextTurn();
          return;
        }

        // For a 6, player gets another roll without moving
        _gameState = LudoGameState.throwDice;
        notifyListeners();
        return;
      } else {
        // Reset consecutive sixes counter for non-6 roll
        _consecutiveSixes = 0;

        // All pawns are inside home and no 6 was rolled
        if (currentPlayer.pawnInsideCount == 4) {
          return nextTurn();
        } else {
          // Highlight all pawns outside home
          currentPlayer.highlightOutside();
          _gameState = LudoGameState.pickPawn;
          notifyListeners();
        }
      }

      ///Check and disable if any pawn already in the finish box
      for (var i = 0; i < currentPlayer.pawns.length; i++) {
        var pawn = currentPlayer.pawns[i];

        // Check if pawn needs exact roll to enter home
        if (pawn.step > -1) {
          int stepsToHome = currentPlayer.path.length - 1 - pawn.step;
          if (stepsToHome < diceResult) {
            // Can't move this pawn as it needs exact roll
            currentPlayer.highlightPawn(i, false);
          }
        }
      }

      ///Automatically move random pawn if all pawn are in same step
      var moveablePawn = currentPlayer.pawns.where((e) => e.highlight).toList();
      if (moveablePawn.length > 1) {
        var biggestStep = moveablePawn.map((e) => e.step).reduce(max);
        if (moveablePawn.every((element) => element.step == biggestStep)) {
          var random = 1 + Random().nextInt(moveablePawn.length - 1);
          if (moveablePawn[random].step == -1) {
            var thePawn = moveablePawn[random];
            move(thePawn.type, thePawn.index, (thePawn.step + 1) + 1);
            return;
          } else {
            var thePawn = moveablePawn[random];
            move(thePawn.type, thePawn.index, (thePawn.step + 1) + diceResult);
            return;
          }
        }
      }

      ///If User have 6 dice, but it inside finish line, it will make him to throw again, else it will turn to next player
      if (currentPlayer.pawns.every((element) => !element.highlight)) {
        nextTurn();
        return;
      }

      if (currentPlayer.pawns.where((element) => element.highlight).length == 1) {
        var index = currentPlayer.pawns.indexWhere((element) => element.highlight);
        move(currentPlayer.type, index, (currentPlayer.pawns[index].step + 1) + diceResult);
      }
    });
  }

  ///Move pawn to next step and check if it can kill other pawn
  void move(LudoPlayerType type, int index, int step) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;

    currentPlayer.highlightAllPawns(false);

    var selectedPlayer = player(type);

    // Check if path is blocked by blockades only for active players
    for (int i = selectedPlayer.pawns[index].step + 1; i < step; i++) {
      for (var otherPlayer in players) {
        if (otherPlayer.type != type && isBlockade(selectedPlayer.path[i], otherPlayer.type)) {
          // Path is blocked, cancel move
          _isMoving = false;
          _gameState = LudoGameState.throwDice;
          nextTurn();
          return;
        }
      }
    }

    // int delay = 500;
    for (int i = selectedPlayer.pawns[index].step; i < step; i++) {
      if (_stopMoving) break;
      if (selectedPlayer.pawns[index].step == i) continue;
      selectedPlayer.movePawn(index, i);
      await Audio.playMove();
      notifyListeners();
      if (_stopMoving) break;
    }
    if (checkToKill(type, index, step, selectedPlayer.path)) {
      _gameState = LudoGameState.throwDice;
      _isMoving = false;
      Audio.playKill();
      notifyListeners();
      return;
    }

    validateWin(type);

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
    int currentIndex = players.indexWhere((p) => p.type == currentTurn);
    if (currentIndex == -1) currentIndex = 0; // Fallback to first player if not found
    currentIndex = (currentIndex + 1) % players.length; // Use players.length instead of _numberOfPlayers
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

  // Modify isBlockade to only check active players
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
    // For now, we'll just print to console
    print("Three consecutive sixes! Turn canceled.");
  }
}
