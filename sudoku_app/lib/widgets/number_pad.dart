import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Wrap(
      spacing: 8,
      children: List.generate(9, (index) {
        int number = index + 1;

        bool isSelected = game.selectedNumber == number;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Colors.grey.shade400
                : Colors.grey.shade200,
          ),
          onPressed: () {
            game.selectNumber(number);
          },
          child: Text(number.toString()),
        );
      }),
    );
  }
}