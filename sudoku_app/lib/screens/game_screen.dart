import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import 'settings_screen.dart';
import 'completion_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();

    final game = Provider.of<GameProvider>(context, listen: false);

    game.onComplete = (difficulty, time) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompletionScreen(
            difficulty: difficulty,
            time: time,
          ),
        ),
      );
    };
  }

  void _openSettings() async {
    final game = Provider.of<GameProvider>(context, listen: false);

    game.pauseTimer();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen()),
    );

    game.resumeTimer();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,

        /// CENTER → TIMER + UNDO REDO
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (game.timerEnabled)
              Text(game.formattedTime),

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

        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
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