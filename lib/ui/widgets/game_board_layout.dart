import 'package:flutter/material.dart';
import '../../widgets/board_widget.dart';
import '../../widgets/dice_widget.dart';

class GameBoardLayout extends StatelessWidget {
  final Widget board;
  final String currentTurn;
  final Function(String playerId) onDiceRoll;

  const GameBoardLayout({
    Key? key,
    required this.board,
    required this.currentTurn,
    required this.onDiceRoll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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

          // Green Player (Top)
          if (currentTurn == 'green')
            Positioned(
              top: 60,
              left: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Player 1',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDice('green'),
                  ],
                ),
              ),
            ),

          // Red Player (Bottom)
          if (currentTurn == 'red')
            Positioned(
              bottom: 60,
              left: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDice('red'),
                    const SizedBox(height: 8),
                    Text(
                      'Player 2',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDice(String playerId) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: 50,
        height: 50,
        child: DiceWidget(),
      ),
    );
  }
}

class PlayerInfo {
  final String id;
  final String name;
  final Color color;
  final Offset position;

  const PlayerInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
  });
}
