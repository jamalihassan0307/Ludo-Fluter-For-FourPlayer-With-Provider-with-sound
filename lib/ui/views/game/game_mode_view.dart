import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/game_mode_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

class GameModeView extends StatelessWidget {
  const GameModeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameModeViewModel(),
      child: const GameModeContent(),
    );
  }
}

class GameModeContent extends StatelessWidget {
  const GameModeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameModeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameModeCard(
              title: 'Play with Friends',
              description: 'Play on the same device with friends',
              icon: Icons.group,
              color: ColorConstants.primaryColor,
              onTap: viewModel.startLocalMultiplayer,
            ),
            const SizedBox(height: 20),
            GameModeCard(
              title: 'Play vs Computer',
              description: 'Challenge our AI opponent',
              icon: Icons.computer,
              color: ColorConstants.secondaryColor,
              onTap: viewModel.startComputerGame,
            ),
            const SizedBox(height: 20),
            GameModeCard(
              title: 'Play Online',
              description: 'Coming Soon!',
              icon: Icons.public,
              color: Colors.grey,
              onTap: viewModel.startOnlineMultiplayer,
              isDisabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

class GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDisabled;

  const GameModeCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isDisabled ? Colors.grey : color,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDisabled ? Colors.grey : Colors.black,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDisabled ? Colors.grey : Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 