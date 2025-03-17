import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ludo_flutter/screens/login_screen.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({Key? key}) : super(key: key);

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final controller = LiquidController();
  int currentPage = 0;

  final pages = [
    const WalkthroughPage(
      title: "Welcome to Ludo",
      description: "Experience the classic board game in a whole new way",
      image: "assets/walkthrough/logo_gaming.jpg",
      backgroundColor: Color(0xFF4A148C),
      textColor: Colors.white,
    ),
    const WalkthroughPage(
      title: "Play with Friends",
      description: "Challenge your friends and family to exciting matches",
      image: "assets/walkthrough/game.png",
      backgroundColor: Color(0xFF1A237E),
      textColor: Colors.white,
    ),
    const WalkthroughPage(
      title: "Start Gaming",
      description: "Ready to roll the dice? Let's get started!",
      image: "assets/walkthrough/gaming.jpeg",
      backgroundColor: Color(0xFF0D47A1),
      textColor: Colors.white,
      isLastPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages,
            liquidController: controller,
            enableSideReveal: true,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            onPageChangeCallback: (index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedSmoothIndicator(
                  activeIndex: currentPage,
                  count: pages.length,
                  effect: const WormEffect(
                    spacing: 16,
                    dotColor: Colors.white54,
                    activeDotColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                if (currentPage == pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mark walkthrough as completed
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('walkthroughCompleted', true);

                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(delay: 200.ms),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalkthroughPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;
  final Color textColor;
  final bool isLastPage;

  const WalkthroughPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
    this.isLastPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 300,
          ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),
          const SizedBox(height: 40),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                title,
                textStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: textColor.withOpacity(0.8),
            ),
          ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, duration: 600.ms),
          if (isLastPage) const SizedBox(height: 100),
        ],
      ),
    );
  }
}
