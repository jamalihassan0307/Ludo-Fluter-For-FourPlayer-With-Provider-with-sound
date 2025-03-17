import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

///Widget for the pawn
class PawnWidget extends StatelessWidget {
  final int index;
  final LudoPlayerType type;
  final int step;
  final bool highlight;

  const PawnWidget(this.index, this.type, {super.key, this.highlight = false, this.step = -1});

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
        alignment: Alignment.center,
        children: [
          if (highlight)
            RippleAnimation(
              color: color,
              minRadius: 20,
              repeat: true,
              ripplesCount: 3,
              child: const SizedBox.shrink(),
            ),
          Consumer<LudoProvider>(
            builder: (context, provider, child) => GestureDetector(
              onTap: () {
                // Show selection dialog
                if (highlight) {
                  _showSelectionDialog(context, provider);
                }
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context, LudoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Move Pawn ${index + 1}?", 
          style: TextStyle(color: provider.currentPlayer.color),
        ),
        content: Text(
          step == -1 
            ? "Move this pawn out of home?" 
            : "Move this pawn ${provider.diceResult} steps forward?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (step == -1) {
                provider.move(type, index, (step + 1) + 1);
              } else {
                provider.move(type, index, (step + 1) + provider.diceResult);
              }
            },
            child: const Text("Move"),
          ),
        ],
      ),
    );
  }
}
