import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, Color> colorOptions = {
    "Blue": Colors.blue,
    "Green": Colors.green,
    "Purple": Colors.purple,
    "Pink": Colors.pink,
    "Yellow": Colors.yellow,
  };

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          ListTile(title: Text("User Number Color")),

          ...colorOptions.entries.map((entry) {
            return RadioListTile<Color>(
              title: Text(entry.key),
              value: entry.value,
              groupValue: game.userColor,
              onChanged: (color) {
                game.setUserColor(color!);
              },
            );
          }),

          SwitchListTile(
            title: Text("Auto Check Mistakes"),
            value: game.autoCheck,
            onChanged: (val) {
              game.toggleAutoCheck();
            },
          ),
        ],
      ),
    );
  }
}