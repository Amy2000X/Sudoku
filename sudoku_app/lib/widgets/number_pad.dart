import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: List.generate(9, (index) {
          int number = index + 1;

          bool isSelected =
              game.mode == InputMode.fast &&
              game.selectedNumber == number;

          bool isComplete = game.isNumberComplete(number);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: isComplete ? 0.0 : 1.0, // 👻 invisible but keeps space
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isSelected
                        ? Colors.grey.shade400
                        : Colors.grey.shade200,
                  ),
                  onPressed: isComplete
                      ? null
                      : () {
                          game.selectNumber(number);
                        },
                  child: Text(
                    number.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}