import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/leaderboard_entry.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leaderboard = StorageService.getLeaderboard();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final entry = leaderboard[index];
          final user = StorageService.getUserById(entry.userId);
          
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(user?.name ?? 'Unknown Player'),
            subtitle: Text('Games Won: ${entry.gamesWon}'),
            trailing: Text('${entry.winRate.toStringAsFixed(1)}%'),
          );
        },
      ),
    );
  }
} 