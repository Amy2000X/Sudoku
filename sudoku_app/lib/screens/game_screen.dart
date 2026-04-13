import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import 'settings_screen.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
        ),
        title: Text("Sudoku"),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: game.undo,
          ),
        ],
      ),
      body: Column(
        children: [
          SudokuGrid(),
          SizedBox(height: 20),
          NumberPad(),
        ],
      ),
    );
  }
}