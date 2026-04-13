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

        return ElevatedButton(
          onPressed: () {
            if (game.mode == InputMode.standard) {
              game.inputNumber(number);
            } else {
              game.selectNumber(number);
            }
          },
          child: Text(number.toString()),
        );
      }),
    );
  }
}