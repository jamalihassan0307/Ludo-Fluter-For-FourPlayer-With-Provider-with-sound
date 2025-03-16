import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
} 