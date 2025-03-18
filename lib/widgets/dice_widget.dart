import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

///Widget for the dice
class DiceWidget extends StatelessWidget {
  final bool isActive;

  const DiceWidget({Key? key, this.isActive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LudoProvider>(
      builder: (context, value, child) {
        // Add safety check
        if (value.players.isEmpty) {
          return const SizedBox.shrink();
        }

        try {
          final bool isThrowDice = isActive && value.gameState == LudoGameState.throwDice;
          
          return RippleAnimation(
            color: isThrowDice
                ? value.currentPlayer.color.withOpacity(0.3)
                : Colors.transparent,
            ripplesCount: 3,
            minRadius: 25,
            repeat: true,
            duration: const Duration(milliseconds: 1500),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isThrowDice ? [
                    BoxShadow(
                      color: value.currentPlayer.color.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: CupertinoButton(
                  onPressed: isActive ? value.throwDice : null,
                  padding: EdgeInsets.zero,
                  child: value.diceStarted && isActive
                      ? Image.asset(
                          "assets/images/dice/draw.gif",
                          fit: BoxFit.contain,
                          width: 35,
                          height: 35,
                        )
                      : Image.asset(
                          "assets/images/dice/${value.diceResult}.png",
                          fit: BoxFit.contain,
                          width: 35,
                          height: 35,
                        ),
                ),
              ),
            ),
          );
        } catch (e) {
          // Fallback if there's an error
          return const SizedBox.shrink();
        }
      },
    );
  }
}
