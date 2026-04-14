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
    "Black": Colors.black,
  };

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🎨 PEN COLOR
            _buildRow(
              label: "Pen Color",
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: colorOptions.entries.map((entry) {
                  final color = entry.value;
                  final isSelected = game.penColor == color;

                  return GestureDetector(
                    onTap: () => game.setUserColor(color),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16),

            /// 🎨 THEME
            _buildRow(
              label: "Theme",
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: themeOptions.entries.map((entry) {
                  final color = entry.value;
                  final isSelected = game.backgroundColor == color;

                  return GestureDetector(
                    onTap: () => game.setBackgroundColor(color),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16),

            /// ⚠️ AUTO CHECK
            _buildRow(
              label: "Auto Check",
              child: Switch(
                value: game.autoCheck,
                onChanged: (_) => game.toggleAutoCheck(),
              ),
            ),

            SizedBox(height: 16),

            /// ⏱ TIMER
            _buildRow(
              label: "Timer",
              child: Switch(
                value: game.timerEnabled,
                onChanged: game.toggleTimer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 REUSABLE ROW
  Widget _buildRow({required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: child,
          ),
        ),
      ],
    );
  }
}