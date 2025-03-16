import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const OnboardingContent(),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            onPageChanged: viewModel.onPageChanged,
            itemCount: AppConstants.walkthroughImages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: AppConstants.walkthroughImages[index],
                title: AppConstants.walkthroughTitles[index],
                description: AppConstants.walkthroughDescriptions[index],
              );
            },
          ),
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: viewModel.skipOnboarding,
              child: const Text('Skip'),
            ),
          ),
          // Next/Get Started button
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: CustomButton(
              text: viewModel.isLastPage ? 'Get Started' : 'Next',
              onPressed: viewModel.isLastPage
                  ? viewModel.completeOnboarding
                  : () {
                      // Implement next page logic
                    },
            ),
          ),
          // Page indicator
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                AppConstants.walkthroughImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewModel.currentPage == index
                        ? ColorConstants.primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 