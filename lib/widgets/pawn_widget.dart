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

                  // Show the dice popup to select which dice to use
                  provider.shouldShowDicePopup = true;
                },
              ),
            ),
        ],
      ),
    );
  }
}
