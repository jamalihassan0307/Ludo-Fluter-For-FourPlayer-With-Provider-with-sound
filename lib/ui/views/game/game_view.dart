import 'package:flutter/material.dart';
import 'package:ludo_flutter/widgets/dice_widget.dart';
import 'package:provider/provider.dart';
import '../../../ludo_provider.dart';
import '../../widgets/game/game_board.dart';
// import '../../widgets/game/dice_widget.dart';
import '../../../constants.dart';
import '../../../core/services/game_history_service.dart';
import '../../../data/models/game_state_model.dart';
import '../../../ui/views/game/game_history_view.dart';

class GameView extends StatelessWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LudoProvider()..startGame(),
      child: const _GameViewContent(),
    );
  }
}

class _GameViewContent extends StatefulWidget {
  const _GameViewContent();

  @override
  State<_GameViewContent> createState() => _GameViewContentState();
}

class _GameViewContentState extends State<_GameViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedGame = ModalRoute.of(context)?.settings.arguments as GameStateModel?;

      if (savedGame != null) {
        context.read<LudoProvider>().loadGameState(savedGame);
      } else {
        // Check for unfinished games
        final unfinishedGames = GameHistoryService.getUnfinishedGames();
        if (unfinishedGames.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Resume Game?'),
              content: const Text('You have unfinished games. Would you like to resume one?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GameHistoryView(),
                      ),
                    );
                  },
                  child: const Text('View Games'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('New Game'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving game
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Game?'),
            content: const Text('Are you sure you want to leave the game?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Consumer<LudoProvider>(
          builder: (context, value, child) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GameBoard(),
                    ],
                  ),
                  // Dice positions for each player
                  if (value.currentTurn == LudoPlayerType.green)
                    const Positioned(
                      top: 100,
                      left: 50,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: DiceWidget(),
                      ),
                    ),
                  if (value.currentTurn == LudoPlayerType.yellow)
                    const Positioned(
                      top: 100,
                      right: 50,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: DiceWidget(),
                      ),
                    ),
                  if (value.currentTurn == LudoPlayerType.red)
                    const Positioned(
                      bottom: 100,
                      left: 50,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: DiceWidget(),
                      ),
                    ),
                  if (value.currentTurn == LudoPlayerType.blue)
                    const Positioned(
                      bottom: 100,
                      right: 50,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: DiceWidget(),
                      ),
                    ),
                  // Game over overlay
                  if (value.winners.length == 3)
                    Container(
                      color: Colors.black.withOpacity(0.8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/images/thankyou.gif"),
                            const Text(
                              "Game Over!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Winners: ${value.winners.map((e) => e.name.toUpperCase()).join(", ")}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Back to Home'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
