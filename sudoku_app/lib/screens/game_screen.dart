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
        /// LEFT → HOME
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        /// CENTER → UNDO / REDO
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed:
                  game.history.isEmpty ? null : game.undo,
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed:
                  game.redoStack.isEmpty ? null : game.redo,
            ),
          ],
        ),

        /// RIGHT → SETTINGS
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          SudokuGrid(),
          SizedBox(height: 10),

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
        ],
      ),
    );
  }
}