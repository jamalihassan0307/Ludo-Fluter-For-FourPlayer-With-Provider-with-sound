import 'package:flutter/material.dart';
import '../../../core/services/game_history_service.dart';
import '../../../data/models/game_state_model.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/constants/app_constants.dart';

class GameHistoryView extends StatelessWidget {
  const GameHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final games = GameHistoryService.getAllGames()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return GameHistoryCard(game: game);
        },
      ),
    );
  }
}

class GameHistoryCard extends StatelessWidget {
  final GameStateModel game;

  const GameHistoryCard({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          'Game ${game.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${game.createdAt.toString().substring(0, 16)}'),
            Text('Mode: ${game.gameMode}'),
            Text(
              game.isCompleted ? 'Completed' : 'In Progress',
              style: TextStyle(
                color: game.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            NavigationService.navigateTo(
              AppConstants.gameRoute,
              arguments: game,
            );
          },
        ),
      ),
    );
  }
} 