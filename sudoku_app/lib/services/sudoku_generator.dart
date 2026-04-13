import 'dart:math';

enum Difficulty { easy, medium, hard, expert }

class SudokuGenerator {
  static List<List<int>> generateSolved() {
    List<List<int>> board =
        List.generate(9, (_) => List.filled(9, 0));

    _fill(board);
    return board;
  }

  static List<List<int>> createPuzzle(
      List<List<int>> solution, Difficulty difficulty) {
    int targetEmpty;

    switch (difficulty) {
      case Difficulty.easy:
        targetEmpty = 35;
        break;
      case Difficulty.medium:
        targetEmpty = 45;
        break;
      case Difficulty.hard:
        targetEmpty = 55;
        break;
      case Difficulty.expert:
        targetEmpty = 60;
        break;
    }

    List<List<int>> puzzle;

    /// 🔥 retry until valid puzzle is created
    do {
      puzzle = solution.map((r) => [...r]).toList();
      _removeNumbers(puzzle, targetEmpty);
    } while (!_isValidPuzzle(puzzle, targetEmpty));

    return puzzle;
  }

  /// ---------- REMOVE NUMBERS ----------
  static void _removeNumbers(
      List<List<int>> board, int targetEmpty) {
    Random rand = Random();

    int empty = 0;
    int attempts = 0;

    while (empty < targetEmpty && attempts < 10000) {
      attempts++;

      int row = rand.nextInt(9);
      int col = rand.nextInt(9);

      if (board[row][col] == 0) continue;

      int backup = board[row][col];
      board[row][col] = 0;

      if (_countSolutions(board) != 1) {
        board[row][col] = backup;
      } else {
        empty++;
      }
    }
  }

  /// ---------- VALID PUZZLE CHECK ----------
  static bool _isValidPuzzle(
      List<List<int>> board, int targetEmpty) {
    int emptyCount = 0;

    for (var row in board) {
      for (var cell in row) {
        if (cell == 0) emptyCount++;
      }
    }

    return emptyCount >= targetEmpty;
  }

  /// ---------- SOLVER (STRICT UNIQUE CHECK) ----------
  static int _countSolutions(List<List<int>> board) {
    int count = 0;

    bool solve() {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (board[r][c] == 0) {
            for (int n = 1; n <= 9; n++) {
              if (_isSafe(board, r, c, n)) {
                board[r][c] = n;

                if (solve()) return true;

                board[r][c] = 0;
              }
            }
            return false;
          }
        }
      }

      count++;
      return count >= 2; // stop early if multiple
    }

    solve();
    return count;
  }

  /// ---------- SAFETY CHECK (FIXED) ----------
  static bool _isSafe(
      List<List<int>> board, int row, int col, int num) {
    // row + column
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
      if (board[i][col] == num) return false;
    }

    // 3x3 block
    int br = row - row % 3;
    int bc = col - col % 3;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[br + r][bc + c] == num) return false;
      }
    }

    return true;
  }

  /// ---------- GENERATE FULL BOARD ----------
  static bool _fill(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          List<int> nums = List.generate(9, (i) => i + 1)..shuffle();

          for (int n in nums) {
            if (_isSafe(board, r, c, n)) {
              board[r][c] = n;

              if (_fill(board)) return true;

              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }
}