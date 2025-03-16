import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/data/models/player_model.dart';
import 'package:ludo_flutter/ludo_player.dart';
import 'package:provider/provider.dart';
import '../../../ludo_provider.dart';
import '../../../widgets/board_widget.dart';
import '../../../widgets/dice_widget.dart';
// import '../../../constants.dart';
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
      try {
        final savedGame = ModalRoute.of(context)?.settings.arguments as GameStateModel?;

        if (savedGame != null) {
          context.read<LudoProvider>().loadGameState(savedGame);
        } else {
          // Safely check for unfinished games
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
      } catch (e) {
        print('Error loading game state: $e');
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
          builder: (context, provider, _) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Game Board
                    const BoardWidget(),

                    // Top Player (Green)
                    Positioned(
                      top: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.players.isEmpty
                                ? 'Player 1'
                                : provider.players
                                    .firstWhere(
                                      (p) => p.type == LudoPlayerType.green,
                                      orElse: () => LudoPlayer(LudoPlayerType.green, name: 'Player 1'),
                                    )
                                    .name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: provider.currentTurn == LudoPlayerType.green
                                  ? Colors.green
                                  : Colors.green.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: provider.currentTurn == LudoPlayerType.green ? () => provider.throwDice() : null,
                            child: Opacity(
                              opacity: provider.currentTurn == LudoPlayerType.green ? 1.0 : 0.5,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                ),
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: DiceWidget(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Player (Red)
                    Positioned(
                      bottom: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: provider.currentTurn == LudoPlayerType.red ? () => provider.throwDice() : null,
                            child: Opacity(
                              opacity: provider.currentTurn == LudoPlayerType.red ? 1.0 : 0.5,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                ),
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: DiceWidget(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.players.isEmpty
                                ? 'Player 2'
                                : provider.players
                                    .firstWhere(
                                      (p) => p.type == LudoPlayerType.red,
                                      orElse: () => LudoPlayer(LudoPlayerType.red, name: 'Player 2'),
                                    )
                                    .name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  provider.currentTurn == LudoPlayerType.red ? Colors.red : Colors.red.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
