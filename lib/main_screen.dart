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

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showTurnIndicator = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Initialize game with correct number of players
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Make sure to reinitialize the game with the correct number of players
      context.read<LudoProvider>().startGame(numberOfPlayers: widget.numberOfPlayers);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Exit Game",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    "Are you sure you want to exit the game? Your progress will be lost.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  "EXIT",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        return shouldPop;
      },
      child: Consumer<LudoProvider>(builder: (context, value, child) {
        if (value.shouldShowDicePopup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && value.shouldShowDicePopup) {
              _showDicePopup(context, value);
              Future.microtask(() => value.shouldShowDicePopup = false);
            }
          });
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF3498DB),
                  Colors.purple.shade300,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Animated background patterns
                  Positioned.fill(
                    child: CustomPaint(
                      painter: AnimatedBackgroundPainter(),
                    ),
                  ),
                  Column(
                    children: [
                      _buildGameHeader(value),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const BoardWidget(),
                            if (_showTurnIndicator)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: value.currentPlayer.color.withOpacity(_animationController.value * 0.3),
                                        width: 3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            _buildDicePositions(value),
                            if (value.winners.length == (widget.numberOfPlayers - 1))
                              _buildGameOverScreen(value),
                          ],
                        ),
                      ),
                      _buildGameFooter(value),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _showTurnIndicator ? 0.8 : 1.0,
            child: FloatingActionButton(
              backgroundColor: value.currentPlayer.color,
              elevation: 8,
              child: const Icon(Icons.help_outline),
              onPressed: () {
                setState(() {
                  _showTurnIndicator = !_showTurnIndicator;
                });
                if (!_showTurnIndicator) {
                  _animationController.reset();
                } else {
                  _animationController.repeat(reverse: true);
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGameHeader(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
         _buildPointsDisplay(provider),
        ],
      ),
    );
  }

  Widget _buildDicePositions(LudoProvider value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boardSize = screenWidth * 0.8; // Approximate board size
    final diceOffset = boardSize * 0.15; // Offset from board edge

    return Stack(
      children: [
        // Red Dice (Bottom Left)
        Positioned(
          bottom: screenHeight * 0.02,
          left: screenWidth * 0.01,
          child: _buildDiceWithLabel(value, LudoPlayerType.red, "Red", Alignment.topCenter),
        ),

        // Green Dice (Top Left)
        if (widget.numberOfPlayers >= 4)
          Positioned(
            top: screenHeight * 0.02,
            left: screenWidth * 0.01,
            child: _buildDiceWithLabel(value, LudoPlayerType.green, "Green", Alignment.bottomCenter),
          ),

        // Yellow Dice (Top Right)
        Positioned(
          top: screenHeight * 0.02,
          right: screenWidth * 0.01,
          child: _buildDiceWithLabel(value, LudoPlayerType.yellow, "Yellow", Alignment.bottomCenter),
        ),

        // Blue Dice (Bottom Right)
        if (widget.numberOfPlayers >= 3)
          Positioned(
            bottom: screenHeight * 0.02,
          right: screenWidth * 0.01,
            child: _buildDiceWithLabel(value, LudoPlayerType.blue, "Blue", Alignment.topCenter),
          ),
      ],
    );
  }

  Widget _buildDiceWithLabel(LudoProvider value, LudoPlayerType type, String label, Alignment alignment) {
    final isCurrentTurn = value.currentTurn == type;
    final isPlayerActive = value.players.any((player) => player.type == type);

    if (!isPlayerActive) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (isCurrentTurn)
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //     decoration: BoxDecoration(
        //       color: _getPlayerColor(type),
        //       borderRadius: BorderRadius.circular(8),
        //       boxShadow: [
        //         BoxShadow(
        //           color: _getPlayerColor(type).withOpacity(0.3),
        //           blurRadius: 4,
        //           spreadRadius: 1,
        //         ),
        //       ],
        //     ),
        //     child: const Text(
        //       "Current Turn",
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 10,
        //       ),
        //     ),
        //   ),
        // const SizedBox(height: 4),
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getPlayerColor(type),
              width: isCurrentTurn ? 2 : 1,
            ),
            boxShadow: isCurrentTurn
                ? [
                    BoxShadow(
                      color: _getPlayerColor(type).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isCurrentTurn ? 1.0 : 0.4,
            child: DiceWidget(isActive: isCurrentTurn),
          ),
        ),
        // const SizedBox(height: 4),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        //   decoration: BoxDecoration(
        //     color: _getPlayerColor(type).withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(4),
        //     border: Border.all(
        //       color: _getPlayerColor(type).withOpacity(0.3),
        //       width: 1,
        //     ),
        //   ),
        //   child: Text(
        //     label,
        //     style: TextStyle(
        //       color: _getPlayerColor(type),
        //       fontWeight: FontWeight.bold,
        //       fontSize: 10,
        //     ),
        //   ),
       
        // ),
      ],
    );
  }

  Widget _buildGameFooter(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.currentPlayer.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: provider.currentPlayer.color),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: provider.currentPlayer.color),
                    const SizedBox(width: 8),
                    Text(
                      "${provider.currentPlayer.type.name}'s Turn",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: provider.currentPlayer.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.currentPlayer.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: provider.currentPlayer.color),
                  boxShadow: [
                    BoxShadow(
                      color: provider.currentPlayer.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.casino, color: provider.currentPlayer.color),
                    const SizedBox(width: 8),
                    Text(
                      "Roll: ${provider.currentTurnDiceRolls.isNotEmpty ? provider.currentTurnDiceRolls.last : '-'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.currentPlayer.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDiceHistory(provider),
        ],
      ),
    );
  }

  Widget _buildPointsDisplay(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: provider.players.map((player) {
          final isCurrentTurn = provider.currentTurn == player.type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentTurn ? player.color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isCurrentTurn ? player.color : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCurrentTurn ? [
                BoxShadow(
                  color: player.color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ] : null,
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: player.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: player.color.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentTurn)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: player.color.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${provider.playerPoints[player.type] ?? 0}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: player.color,
                  ),
                ),
                Text(
                  player.type.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: player.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiceHistory(LudoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Dice History",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.currentPlayer.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${provider.currentTurnDiceRolls.length} rolls",
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.currentPlayer.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 50, // Fixed height for dice history
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: provider.currentTurnDiceRolls.map((roll) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: provider.currentPlayer.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: provider.currentPlayer.color,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: provider.currentPlayer.color.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/dice/$roll.png",
                        width: 28,
                        height: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(LudoProvider provider) {
    return Container(
      color: Colors.black.withOpacity(0.85),
                        child: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                Image.asset("assets/images/thankyou.gif", height: 150),
                const SizedBox(height: 16),
                const Text(
                  "Thank you for playing! 😊",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "The Winners are:",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...provider.winners
                    .map((winner) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getPlayerColor(winner).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: _getPlayerColor(winner)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_events, color: _getPlayerColor(winner)),
                                const SizedBox(width: 8),
                                Text(
                                  winner.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getPlayerColor(winner),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
                const SizedBox(height:
                 20),
                const Divider(),
                const SizedBox(height: 8),
                              const Text(
                                  "This game made with Flutter ❤️ by Ali Hassan",
                                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.startGame(numberOfPlayers: widget.numberOfPlayers);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Play Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LudoColor.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPlayerColor(LudoPlayerType type) {
    switch (type) {
      case LudoPlayerType.red:
        return LudoColor.red;
      case LudoPlayerType.green:
        return LudoColor.green;
      case LudoPlayerType.yellow:
        return LudoColor.yellow;
      case LudoPlayerType.blue:
        return LudoColor.blue;
    }
  }

  void _showDicePopup(BuildContext context, LudoProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: provider.currentPlayer.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            provider.consecutiveSixes == 3 ? "Three consecutive sixes! Turn canceled." : "Your Dice Rolls",
            style: TextStyle(
              color: provider.currentPlayer.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            provider.consecutiveSixes == 3
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: const Text(
                      "Your turn is canceled because you rolled three sixes in a row.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Text(
                    "Select a dice to move your pawn:",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
            const SizedBox(height: 20),
            // Replace GridView with Wrap
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
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
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: provider.currentPlayer.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: provider.currentPlayer.color,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: provider.currentPlayer.color.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/dice/$roll.png",
                        width: 45,
                        height: 45,
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
            style: TextButton.styleFrom(
              foregroundColor: provider.currentPlayer.color,
            ),
            child: Text(
              provider.consecutiveSixes == 3 ? "OK" : "Cancel",
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          content: Row(
            children: [
              Icon(Icons.info_outline, color: provider.currentPlayer.color),
              const SizedBox(width: 12),
              Text("No pawns can move with dice roll $diceRoll"),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: provider.currentPlayer.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Select Pawn to Move",
            style: TextStyle(
              color: provider.currentPlayer.color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Which pawn do you want to move $diceRoll steps?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: provider.currentPlayer.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: provider.currentPlayer.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
            style: TextButton.styleFrom(
              foregroundColor: provider.currentPlayer.color,
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    const spacing = 30.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final radius = (i * 40.0) % 120 + 20;
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.3),
        radius,
        circlePaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7),
        radius,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
