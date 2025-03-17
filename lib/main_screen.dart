import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:ludo_flutter/widgets/board_widget.dart';
import 'package:ludo_flutter/widgets/dice_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final int numberOfPlayers;

  const MainScreen({Key? key, required this.numberOfPlayers}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize game with correct number of players
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Make sure to reinitialize the game with the correct number of players
      context.read<LudoProvider>().startGame(numberOfPlayers: widget.numberOfPlayers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LudoProvider>(builder: (context, value, child) {
      // Show dice popup if needed
      if (value.shouldShowDicePopup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDicePopup(context, value);
          // Reset flag after showing popup
          value.shouldShowDicePopup = false;
        });
      }

      return Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BoardWidget(),
                ],
              ),

              // Display dice based on current turn
              if (value.currentTurn == LudoPlayerType.green)
                Positioned(top: 100, left: 50, child: SizedBox(width: 50, height: 50, child: DiceWidget())),

              if (value.currentTurn == LudoPlayerType.yellow)
                Positioned(top: 100, right: 50, child: SizedBox(width: 50, height: 50, child: DiceWidget())),

              if (value.currentTurn == LudoPlayerType.red)
                Positioned(bottom: 100, left: 50, child: SizedBox(width: 50, height: 50, child: DiceWidget())),

              if (value.currentTurn == LudoPlayerType.blue)
                Positioned(bottom: 100, right: 50, child: SizedBox(width: 50, height: 50, child: DiceWidget())),

              // Show player points
              Positioned(
                top: 20,
                child: _buildPointsDisplay(value),
              ),

              // Show dice roll history at the bottom
              Positioned(
                bottom: 20,
                child: _buildDiceHistory(value),
              ),

              // Game over screen
              Consumer<LudoProvider>(
                builder: (context, value, child) => value.winners.length == (widget.numberOfPlayers - 1)
                    ? Container(
                        color: Colors.black.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/thankyou.gif"),
                              const Text("Thank you for playing 😙",
                                  style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center),
                              Text("The Winners are: ${value.winners.map((e) => e.name.toUpperCase()).join(", ")}",
                                  style: const TextStyle(color: Colors.white, fontSize: 30),
                                  textAlign: TextAlign.center),
                              const Divider(color: Colors.white),
                              const Text("This game made with Flutter ❤️ by Ali Hassan",
                                  style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              const Text("Refresh your browser to play again",
                                  style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Add a method to build the points display
  Widget _buildPointsDisplay(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: provider.players.map((player) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: player.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: provider.currentTurn == player.type ? player.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              "${player.type.name}: ${provider.playerPoints[player.type] ?? 0}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: player.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Add a method to build the dice history
  Widget _buildDiceHistory(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Current Turn Dice Rolls:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: provider.currentTurnDiceRolls.map((roll) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: provider.currentPlayer.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/dice/$roll.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDicePopup(BuildContext context, LudoProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          provider.consecutiveSixes == 3 ? "Three consecutive sixes! Turn canceled." : "Your Dice Rolls",
          style: TextStyle(color: provider.currentPlayer.color, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            provider.consecutiveSixes == 3
                ? const Text("Your turn is canceled because you rolled three sixes in a row.")
                : const Text("Select a dice to move your pawn:"),
            const SizedBox(height: 15),
            // Grid of dice images
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: provider.currentTurnDiceRolls.map((roll) {
                return InkWell(
                  onTap: provider.consecutiveSixes == 3
                      ? null
                      : () {
                          Navigator.pop(context);
                          // Show pawn selection dialog
                          _showPawnSelectionDialog(context, provider, roll);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: provider.currentPlayer.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: provider.currentPlayer.color,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/dice/$roll.png",
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (provider.consecutiveSixes == 3) {
                // Turn is already being canceled in the provider
              }
            },
            child: Text(
              provider.consecutiveSixes == 3 ? "OK" : "Cancel",
              style: TextStyle(color: provider.currentPlayer.color),
            ),
          ),
        ],
      ),
    );
  }

  void _showPawnSelectionDialog(BuildContext context, LudoProvider provider, int diceRoll) {
    // Get movable pawns for this dice roll
    List<int> movablePawnIndices = [];
    for (int i = 0; i < provider.currentPlayer.pawns.length; i++) {
      if (provider.currentPlayer.pawns[i].highlight) {
        // For pawns in home, only allow if dice is 6
        if (provider.currentPlayer.pawns[i].step == -1) {
          if (diceRoll == 6) {
            movablePawnIndices.add(i);
          }
        } else {
          // For pawns on board, check if they can move with this dice roll
          int newStep = provider.currentPlayer.pawns[i].step + diceRoll;
          if (newStep < provider.currentPlayer.path.length) {
            movablePawnIndices.add(i);
          } else if (newStep == provider.currentPlayer.path.length - 1) {
            // Exact roll to home
            movablePawnIndices.add(i);
          }
        }
      }
    }

    if (movablePawnIndices.isEmpty) {
      // No pawns can move with this dice roll
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No pawns can move with dice roll $diceRoll"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (movablePawnIndices.length == 1) {
      // Only one pawn can move, move it automatically
      provider.moveWithDiceRoll(provider.currentPlayer.type, movablePawnIndices[0], diceRoll);
      return;
    }

    // Multiple pawns can move, show selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Select Pawn to Move",
          style: TextStyle(color: provider.currentPlayer.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Which pawn do you want to move $diceRoll steps?"),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: movablePawnIndices.map((index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      provider.moveWithDiceRoll(provider.currentPlayer.type, index, diceRoll);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: provider.currentPlayer.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
