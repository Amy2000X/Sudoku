import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Column(
      children: [
        _buildPenRow(game),
        if (game.pencilMode) _buildPencilRow(game),
      ],
    );
  }

  /// 🔢 PEN ROW
  Widget _buildPenRow(GameProvider game) {
    return Row(
      children: List.generate(9, (index) {
        int number = index + 1;

        bool isSelected =
            !game.isPencilSelected &&
            game.selectedNumber == number &&
            game.mode == InputMode.fast;

        bool isComplete = game.isNumberComplete(number);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Opacity(
              opacity: isComplete ? 0.0 : 1.0, // 👻 hide when done
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.grey.shade400
                      : Colors.grey.shade200,
                ),
                onPressed: isComplete
                    ? null
                    : () => game.selectNumber(number),
                child: Text(number.toString()),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// ✏️ PENCIL ROW
  Widget _buildPencilRow(GameProvider game) {
    return Row(
      children: List.generate(9, (index) {
        int number = index + 1;

        bool isSelected =
            game.isPencilSelected &&
            game.selectedNumber == number;

        bool isComplete = game.isNumberComplete(number);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Opacity(
              opacity: isComplete ? 0.0 : 1.0, // 👻 hide here too
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.grey.shade500
                      : Colors.grey.shade300,
                ),
                onPressed: isComplete
                    ? null
                    : () => game.selectPencilNumber(number),
                child: Text(
                  number.toString(),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}