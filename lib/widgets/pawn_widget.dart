import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

///Widget for the pawn
class PawnWidget extends StatelessWidget {
  final LudoPlayerType type;
  final int index;
  final int step;
  final bool highlight;

  const PawnWidget({
    Key? key,
    required this.type,
    required this.index,
    required this.step,
    required this.highlight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    switch (type) {
      case LudoPlayerType.green:
        color = LudoColor.green;
        break;
      case LudoPlayerType.yellow:
        color = LudoColor.yellow;
        break;
      case LudoPlayerType.blue:
        color = LudoColor.blue;
        break;
      case LudoPlayerType.red:
        color = LudoColor.red;
        break;
    }
    
    Widget pawnContent = Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          "",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );

    if (highlight) {
      pawnContent = RippleAnimation(
        color: color.withOpacity(0.3),
        delay: const Duration(milliseconds: 300),
        repeat: true,
        minRadius: 20,
        ripplesCount: 3,
        duration: const Duration(milliseconds: 1500),
        child: Stack(
          children: [
            pawnContent,
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
              ),
            ),
          ],
        ),
      );
    }

    return IgnorePointer(
      ignoring: !highlight,
      child: GestureDetector(
        onTap: highlight ? () => _handlePawnTap(context) : null,
        child: pawnContent,
      ),
    );
  }

  void _handlePawnTap(BuildContext context) {
    final provider = Provider.of<LudoProvider>(context, listen: false);

    if (provider.currentTurnDiceRolls.length == 1) {
      // Only one dice roll, move directly
      int diceRoll = provider.currentTurnDiceRolls[0];
      provider.currentTurnDiceRolls.remove(diceRoll);

      if (step == -1) {
        // Move out of home (requires a 6)
        if (diceRoll == 6) {
          provider.move(type, index, 0);
        }
      } else {
        // Move forward
        provider.move(type, index, step + diceRoll);
      }
    } else {
      // Multiple dice rolls, show selection dialog
      _showDiceSelectionDialog(context, provider);
    }
  }

  void _showDiceSelectionDialog(BuildContext context, LudoProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Select Dice to Move",
          style: TextStyle(color: provider.currentPlayer.color, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Which dice do you want to use for Pawn ${index + 1}?"),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: provider.currentTurnDiceRolls.map((roll) {
                // Check if this dice can be used for this pawn
                bool canUse = true;
                if (step == -1 && roll != 6) {
                  canUse = false; // Can't move out of home without a 6
                }

                return Opacity(
                  opacity: canUse ? 1.0 : 0.3,
                  child: InkWell(
                    onTap: canUse
                        ? () {
                            Navigator.pop(context);
                            if (step == -1) {
                              provider.move(type, index, 0);
                            } else {
                              provider.move(type, index, step + roll);
                            }
                            // Remove the used dice roll
                            provider.currentTurnDiceRolls.remove(roll);
                          }
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
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
                          width: 30,
                          height: 30,
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
            child: Text(
              "Cancel",
              style: TextStyle(color: provider.currentPlayer.color),
            ),
          ),
        ],
      ),
    );
  }
}
