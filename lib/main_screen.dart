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
}
