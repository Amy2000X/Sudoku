import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../services/sudoku_generator.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
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

          SwitchListTile(
            title: Text("Fast Mode"),
            value: game.mode == InputMode.fast,
            onChanged: (_) => game.toggleMode(),
          ),

          SwitchListTile(
            title: Text("Pencil Mode"),
            value: game.pencilMode,
            onChanged: (_) => game.togglePencil(),
          ),

          NumberPad(),

          ElevatedButton(
            onPressed: () =>
                game.newGame(Difficulty.medium),
            child: Text("New Game"),
          )
        ],
      ),
    );
  }
}