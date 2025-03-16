import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../ui/views/leaderboard/leaderboard_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await StorageService.clearUser();
              NavigationService.navigateTo(AppConstants.loginRoute);
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        child: const HomeContent(),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Image.asset(
              'assets/logo.jpg',
              height: 150,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'New Game',
              onPressed: viewModel.startNewGame,
            ),
            const SizedBox(height: 16),
            if (viewModel.hasSavedGame) ...[
              CustomButton(
                text: 'Continue Game',
                onPressed: viewModel.continueGame,
                color: ColorConstants.secondaryColor,
              ),
              const SizedBox(height: 16),
            ],
            CustomButton(
              text: 'Join Game',
              onPressed: viewModel.joinGame,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Settings',
              onPressed: viewModel.openSettings,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Leaderboard',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardView()),
              ),
              color: Colors.purple,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
