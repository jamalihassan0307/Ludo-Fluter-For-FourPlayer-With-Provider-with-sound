import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ludo_provider.dart';
import '../../../widgets/board_widget.dart';
import '../../../widgets/dice_widget.dart';
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
          builder: (context, provider, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                const BoardWidget(),
                
                // Player 1 (Green) - Top
                if (provider.currentTurn == PlayerType.green)
                  Positioned(
                    top: 20,
                    child: Column(
                      children: [
                        Text(
                          provider.players.firstWhere((p) => p.type == PlayerType.green).name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: DiceWidget(),
                        ),
                      ],
                    ),
                  ),

                // Player 2 (Red) - Bottom
                if (provider.currentTurn == PlayerType.red)
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: DiceWidget(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.players.firstWhere((p) => p.type == PlayerType.red).name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
