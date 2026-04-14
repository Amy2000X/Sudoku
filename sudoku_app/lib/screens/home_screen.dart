import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/sudoku_generator.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startGame(BuildContext context, Difficulty difficulty) {
    final game = Provider.of<GameProvider>(context, listen: false);
    game.newGame(difficulty);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select Difficulty"),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.easy),
              child: Text("Easy"),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.medium),
              child: Text("Medium"),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.hard),
              child: Text("Hard"),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, Difficulty.expert),
              child: Text("Expert"),
            ),
          ],
        ),
      ),
    );
  }
}