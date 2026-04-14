import 'dart:math';

enum Difficulty { easy, medium, hard, expert }

class SudokuGenerator {
  static final Random _random = Random();

  /// ================= PUBLIC API =================

  static List<List<int>> generateSolved() {
    List<List<int>> board =
        List.generate(9, (_) => List.generate(9, (_) => 0));

    _fillBoard(board);
    return board;
  }

  static List<List<int>> createPuzzle(
      List<List<int>> solution, Difficulty difficulty) {
    List<List<int>> puzzle =
        solution.map((row) => List<int>.from(row)).toList();

    int removeCount = _getRemoveCount(difficulty);

    int attempts = 0;
    const maxAttempts = 500;

    while (removeCount > 0 && attempts < maxAttempts) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      if (puzzle[row][col] == 0) {
        attempts++;
        continue;
      }

      int backup = puzzle[row][col];
      puzzle[row][col] = 0;

      List<List<int>> copy =
          puzzle.map((r) => List<int>.from(r)).toList();

      int solutions = _countSolutions(copy);

      if (solutions != 1) {
        puzzle[row][col] = backup;
        attempts++;
      } else {
        removeCount--;
      }
    }

    return puzzle;
  }

  /// ================= INTERNAL =================

  static bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1);
          numbers.shuffle(_random);

          for (int num in numbers) {
            if (_isValid(board, row, col, num)) {
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

  /// Cells removed per difficulty
  static int _getRemoveCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 35;
      case Difficulty.medium:
        return 45;
      case Difficulty.hard:
        return 55;
      case Difficulty.expert:
        return 58;
    }
  }

  static bool _isValid(
      List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
      if (board[i][col] == num) return false;
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[startRow + r][startCol + c] == num) {
          return false;
        }
      }
    }

    return true;
  }

  /// ================= SOLVER =================

  static int _countSolutions(List<List<int>> board) {
    int count = 0;

    bool solve() {
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (board[row][col] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (_isValid(board, row, col, num)) {
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

      /// EARLY EXIT
      return count >= 2;
    }

    solve();
    return count;
  }
}