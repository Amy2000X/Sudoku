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

  /// ✅ NEW: track gesture type
  bool _isSwiping = false;

  void _handleTouch(BuildContext context, Offset globalPosition) {
    final game = Provider.of<GameProvider>(context, listen: false);

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);

    double size = box.size.width / 9;

    int col = (local.dx ~/ size).clamp(0, 8);
    int row = (local.dy ~/ size).clamp(0, 8);

    /// Only trigger if new cell
    if (row == lastRow && col == lastCol) return;

    lastRow = row;
    lastCol = col;

    game.selectTile(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        /// ✅ TAP (only if not swiping)
        onTapDown: (details) {
          if (!_isSwiping) {
            lastRow = null;
            lastCol = null;
            _handleTouch(context, details.globalPosition);
          }
        },

        /// ✅ SWIPE START
        onPanStart: (details) {
          _isSwiping = true;
          lastRow = null;
          lastCol = null;
          _handleTouch(context, details.globalPosition);
        },

        /// ✅ SWIPE MOVE
        onPanUpdate: (details) {
          _handleTouch(context, details.globalPosition);
        },

        /// ✅ RESET
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
                    ? _buildNotes(game.notes[row][col])
                    : Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 20,
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

  /// NOTES
  Widget _buildNotes(Set<int> notes) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (r) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (c) {
              int number = r * 3 + c + 1;

              return SizedBox(
                width: 14,
                height: 14,
                child: Center(
                  child: Text(
                    notes.contains(number) ? number.toString() : "",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
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