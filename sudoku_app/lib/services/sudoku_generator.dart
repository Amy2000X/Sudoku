import 'dart:math';

enum Difficulty { easy, medium, hard, expert }

class SudokuGenerator {
  /// ---------- PUBLIC API ----------

  static List<List<int>> generateSolved() {
    List<List<int>> board =
        List.generate(9, (_) => List.filled(9, 0));

    _fillBoard(board);
    return board;
  }

  static List<List<int>> createPuzzle(
      List<List<int>> solution, Difficulty difficulty) {
    List<List<int>> puzzle =
        solution.map((row) => [...row]).toList();

    int removeCount;

    switch (difficulty) {
      case Difficulty.easy:
        removeCount = 35;
        break;
      case Difficulty.medium:
        removeCount = 45;
        break;
      case Difficulty.hard:
        removeCount = 55;
        break;
      case Difficulty.expert:
        removeCount = 60;
        break;
    }

    _removeNumbers(puzzle, removeCount);
    return puzzle;
  }

  /// ---------- GENERATION ----------

  static bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> nums =
              List.generate(9, (i) => i + 1)..shuffle();

          for (int num in nums) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;

              if (_fillBoard(board)) return true;

              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static void _removeNumbers(
      List<List<int>> board, int removeCount) {
    Random rand = Random();

    while (removeCount > 0) {
      int row = rand.nextInt(9);
      int col = rand.nextInt(9);

      if (board[row][col] == 0) continue;

      int backup = board[row][col];
      board[row][col] = 0;

      /// 🔥 THIS is where uniqueness is enforced
      int solutions = _countSolutions(board);

      if (solutions != 1) {
        board[row][col] = backup;
      } else {
        removeCount--;
      }
    }
  }

  /// ---------- SOLVER (counts solutions) ----------

  static int _countSolutions(List<List<int>> board) {
    int count = 0;

    bool solve() {
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (board[row][col] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (_isSafe(board, row, col, num)) {
                board[row][col] = num;

                if (solve()) return true;

                board[row][col] = 0;
              }
            }
            return false;
          }
        }
      }

      count++;
      return count >= 2; // stop early if >1
    }

    solve();
    return count;
  }

  /// ---------- VALIDATION ----------

  static bool _isSafe(
      List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num ||
          board[i][col] == num ||
          board[row - row % 3 + i ~/ 3]
                  [col - col % 3 + i % 3] ==
              num) {
        return false;
      }
    }
    return true;
  }
}