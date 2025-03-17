import 'package:flutter/material.dart';
import 'package:ludo_flutter/main_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LUDO GAME',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              _buildPlayerCard(
                context,
                'assets/images/board.png',
                '2 Players',
                2,
              ),
              const SizedBox(height: 20),
              _buildPlayerCard(
                context,
                'assets/images/board.png',
                '3 Players',
                3,
              ),
              const SizedBox(height: 20),
              _buildPlayerCard(
                context,
                'assets/images/board.png',
                '4 Players',
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
      BuildContext context, String image, String title, int players) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(numberOfPlayers: players),
            ),
          );
        },
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Image.asset(
                image,
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 