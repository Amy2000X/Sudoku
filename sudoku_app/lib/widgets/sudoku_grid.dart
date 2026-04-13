import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SudokuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 81,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 9;
          int col = index % 9;

          bool isSelected =
              game.selectedRow == row && game.selectedCol == col;

          int value = game.board[row][col];
          bool isGiven = game.isGiven[row][col];
          bool isWrong = game.isWrong(row, col);

          Color textColor;
          FontWeight weight = FontWeight.normal;

          if (isGiven) {
            textColor = Colors.black;
            weight = FontWeight.bold;
          } else if (isWrong) {
            textColor = Colors.red;
          } else {
            textColor = game.userColor;
          }

          return GestureDetector(
            onTap: () => game.selectTile(row, col),
            child: Container(
              decoration: BoxDecoration(
                color: isWrong
                    ? Colors.red.withOpacity(0.2)
                    : isSelected
                        ? Colors.black.withOpacity(0.1)
                        : Colors.transparent,
                border: Border(
                  top: BorderSide(width: row % 3 == 0 ? 2 : 0.5),
                  left: BorderSide(width: col % 3 == 0 ? 2 : 0.5),
                  right: BorderSide(width: col == 8 ? 2 : 0.5),
                  bottom: BorderSide(width: row == 8 ? 2 : 0.5),
                ),
              ),
              child: Center(
                child: value == 0
                    ? SizedBox()
                    : Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                          fontWeight: weight,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}