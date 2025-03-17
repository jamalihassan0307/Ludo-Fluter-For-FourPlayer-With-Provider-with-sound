import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:provider/provider.dart';

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
    return IgnorePointer(
      ignoring: !highlight,
      child: Stack(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text(
                "",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          if (highlight)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: InkWell(
                onTap: () {
                  // Get the provider
                  final provider = Provider.of<LudoProvider>(context, listen: false);

                  // Check if there are multiple dice rolls
                  if (provider.currentTurnDiceRolls.length > 1) {
                    // Show the dice popup
                    provider.shouldShowDicePopup = true;
                  } else if (provider.currentTurnDiceRolls.length == 1) {
                    // Only one dice roll, move directly
                    int diceRoll = provider.currentTurnDiceRolls[0];

                    // Move the pawn
                    if (step == -1) {
                      // Move out of home (requires a 6)
                      if (diceRoll == 6) {
                        provider.moveWithDiceRoll(type, index, diceRoll);
                      }
                    } else {
                      // Move forward
                      provider.moveWithDiceRoll(type, index, diceRoll);
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
