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
                Positioned(
                  top: 100, 
                  left: 50, 
                  child: SizedBox(width: 50, height: 50, child: DiceWidget())
                ),
                
              if (value.currentTurn == LudoPlayerType.yellow)
                Positioned(
                  top: 100, 
                  right: 50, 
                  child: SizedBox(width: 50, height: 50, child: DiceWidget())
                ),
                
              if (value.currentTurn == LudoPlayerType.red)
                Positioned(
                  bottom: 100, 
                  left: 50, 
                  child: SizedBox(width: 50, height: 50, child: DiceWidget())
                ),
                
              if (value.currentTurn == LudoPlayerType.blue)
                Positioned(
                  bottom: 100, 
                  right: 50, 
                  child: SizedBox(width: 50, height: 50, child: DiceWidget())
                ),
              
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

  // Add a method to build the dice roll history
  Widget _buildDiceHistory(LudoProvider provider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Dice History: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          // Here you would show the dice history
          // This requires adding a diceHistory list to the LudoProvider
          // For now, just showing the current dice
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: provider.currentPlayer.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "${provider.diceResult}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDicePopup(BuildContext context, LudoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Dice Rolls",
          style: TextStyle(color: provider.currentPlayer.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You rolled the following dice:"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: provider.currentTurnDiceRolls.map((roll) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: provider.currentPlayer.color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "$roll",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              provider.currentTurnDiceRolls.contains(6)
                  ? "You can move a pawn out of home or move an existing pawn"
                  : "You can move an existing pawn",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
