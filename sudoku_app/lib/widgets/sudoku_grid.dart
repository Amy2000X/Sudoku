import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SudokuGrid extends StatefulWidget {
  @override
  State<SudokuGrid> createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid> {
  int? lastRow;
  int? lastCol;

  bool _isSwiping = false;

  void _handleTouch(BuildContext context, Offset globalPosition) {
    final game = Provider.of<GameProvider>(context, listen: false);

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);

    double size = box.size.width / 9;

    int col = (local.dx ~/ size).clamp(0, 8);
    int row = (local.dy ~/ size).clamp(0, 8);

    if (row == lastRow && col == lastCol) return;

    lastRow = row;
    lastCol = col;

    game.selectTile(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    double gridSize = MediaQuery.of(context).size.width;
    double cellSize = gridSize / 9;

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTapDown: (details) {
          if (!_isSwiping) {
            lastRow = null;
            lastCol = null;
            _handleTouch(context, details.globalPosition);
          }
        },

        onPanStart: (details) {
          _isSwiping = true;
          lastRow = null;
          lastCol = null;
          _handleTouch(context, details.globalPosition);
        },

        onPanUpdate: (details) {
          _handleTouch(context, details.globalPosition);
        },

        onPanEnd: (_) {
          _isSwiping = false;
          lastRow = null;
          lastCol = null;
        },

        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: 81,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemBuilder: (context, index) {
            int row = index ~/ 9;
            int col = index % 9;

            int value = game.board[row][col];
            bool isGiven = game.isGiven[row][col];
            bool isWrong = game.isWrong(row, col);
            bool isSelected =
                game.selectedRow == row && game.selectedCol == col;

            bool highlight = game.shouldHighlight(row, col);

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

            Color bgColor = Colors.transparent;

            if (isWrong) {
              bgColor = Colors.red.withOpacity(0.2);
            } else if (highlight) {
              bgColor = Colors.black.withOpacity(0.1);
            } else if (isSelected) {
              bgColor = Colors.black.withOpacity(0.15);
            }

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(width: row % 3 == 0 ? 2 : 0.5),
                  left: BorderSide(width: col % 3 == 0 ? 2 : 0.5),
                  right: BorderSide(width: col == 8 ? 2 : 0.5),
                  bottom: BorderSide(width: row == 8 ? 2 : 0.5),
                ),
              ),
              child: Center(
                child: value == 0
                    ? _buildNotes(
                        game,
                        game.notes[row][col],
                        row,
                        col,
                        cellSize,
                      )
                    : Text(
                        value.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: cellSize * 0.5, // ✅ responsive
                          color: textColor,
                          fontWeight: weight,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ UPDATED NOTES
  Widget _buildNotes(
    GameProvider game,
    Set<int> notes,
    int row,
    int col,
    double cellSize,
  ) {
    double noteSize = cellSize / 3.5;

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (r) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (c) {
              int number = r * 3 + c + 1;

              bool hasNote = notes.contains(number);

              bool isHighlighted = game.selectedNumber != null &&
                  number == game.selectedNumber;

              return SizedBox(
                width: noteSize,
                height: noteSize,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      hasNote ? number.toString() : "",
                      style: TextStyle(
                        fontSize: noteSize * 0.6,
                        color: hasNote
                            ? (isHighlighted
                                ? game.userColor
                                : Colors.grey)
                            : Colors.transparent,
                        fontWeight: isHighlighted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}