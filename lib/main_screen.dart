import 'package:flutter/material.dart';
import 'package:ludo_flutter/constants.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:ludo_flutter/widgets/board_widget.dart';
import 'package:ludo_flutter/widgets/dice_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LudoProvider>(builder: (context, value, child) {
      return Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BoardWidget(),
                ],
              ),
              if (value.currentTurn == LudoPlayerType.green)
                Positioned(
                    top: 100,
                    left: 50,
                    child:
                        SizedBox(width: 50, height: 50, child: DiceWidget())),
              if (value.currentTurn == LudoPlayerType.yellow)
                Positioned(
                    top: 100,
                    right: 50,
                    child:
                        SizedBox(width: 50, height: 50, child: DiceWidget())),
              if (value.currentTurn == LudoPlayerType.red)
                Positioned(
                    bottom: 100,
                    left: 50,
                    child:
                        SizedBox(width: 50, height: 50, child: DiceWidget())),
              if (value.currentTurn == LudoPlayerType.blue)
                Positioned(
                    bottom: 100,
                    right: 50,
                    child:
                        SizedBox(width: 50, height: 50, child: DiceWidget())),
              Consumer<LudoProvider>(
                builder: (context, value, child) => value.winners.length == 3
                    ? Container(
                        color: Colors.black.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/thankyou.gif"),
                              const Text("Thank you for playing 😙",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                  textAlign: TextAlign.center),
                              Text(
                                  "The Winners is: ${value.winners.map((e) => e.name.toUpperCase()).join(", ")}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 30),
                                  textAlign: TextAlign.center),
                              const Divider(color: Colors.white),
                              const Text(
                                  "This game made with Flutter ❤️ by Ali Hassan",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              const Text("Refresh your browser to play again",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
