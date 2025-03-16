import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/lobby_viewmodel.dart';
import '../../../data/models/player_model.dart';
import '../../widgets/common/custom_button.dart';

class LobbyView extends StatelessWidget {
  const LobbyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LobbyViewModel(),
      child: const LobbyContent(),
    );
  }
}

class LobbyContent extends StatelessWidget {
  const LobbyContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LobbyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Players',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.players.length,
                itemBuilder: (context, index) {
                  final player = viewModel.players[index];
                  return PlayerCard(
                    player: player,
                    onRemove: player.isBot ? null : () => viewModel.removePlayer(player.id),
                  );
                },
              ),
            ),
            if (viewModel.players.length < 4) ...[
              const SizedBox(height: 20),
              CustomButton(
                text: 'Add Player',
                onPressed: () {
                  // Show add player dialog
                  showDialog(
                    context: context,
                    builder: (context) => AddPlayerDialog(
                      onAdd: (name) {
                        viewModel.addPlayer(PlayerModel(
                          id: DateTime.now().toString(),
                          name: name,
                          type: PlayerType.values[viewModel.players.length],
                        ));
                      },
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            CustomButton(
              text: 'Start Game',
              onPressed: viewModel.canStartGame ? viewModel.startGame : null,
              color: viewModel.canStartGame ? ColorConstants.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onRemove;

  const PlayerCard({
    Key? key,
    required this.player,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: player.color,
          child: Text(
            player.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(player.name),
        subtitle: Text(player.isBot ? 'Computer' : 'Human Player'),
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}

class AddPlayerDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddPlayerDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Player'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Player Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
