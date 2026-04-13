import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sudoku_generator.dart';
import '../models/move.dart';

enum InputMode { standard, fast }
enum GameState { playing, completed, paused }

class GameProvider extends ChangeNotifier {
  late List<List<int>> board;
  late List<List<int>> solution;
  late List<List<bool>> isGiven;

  List<Move> history = [];
  List<Move> redoStack = [];

  int? selectedRow;
  int? selectedCol;
  int? selectedNumber;

  InputMode mode = InputMode.standard;
  bool autoCheck = true;
  bool timerEnabled = true;

  Color userColor = Colors.blue;

  Timer? _timer;
  int seconds = 0;

  GameState state = GameState.playing;
  Difficulty? currentDifficulty;

  Function(Difficulty diff, String time)? onComplete;

  /// ---------- TIMER ----------
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      seconds++;
      notifyListeners();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (state != GameState.playing) return;
    _startTimer();
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  /// ---------- SETTINGS ----------
  void setUserColor(Color color) {
    userColor = color;
    notifyListeners();
  }

  void toggleAutoCheck() {
    autoCheck = !autoCheck;
    notifyListeners();
  }

  void toggleTimer(bool value) {
    timerEnabled = value;
    notifyListeners();
  }

  /// ---------- NEW GAME ----------
  void newGame(Difficulty difficulty) {
    currentDifficulty = difficulty;
    state = GameState.playing;

    final full = SudokuGenerator.generateSolved();

    solution = full.map((r) => [...r]).toList();
    board = SudokuGenerator.createPuzzle(full, difficulty);

    isGiven = List.generate(
      9,
      (r) => List.generate(9, (c) => board[r][c] != 0),
    );

    history.clear();
    redoStack.clear();

    selectedRow = null;
    selectedCol = null;
    selectedNumber = null;

    seconds = 0;
    _startTimer();

    notifyListeners();
  }

  /// ---------- MODE SWITCH ----------
  void toggleMode() {
    mode =
        mode == InputMode.standard ? InputMode.fast : InputMode.standard;

    /// FULL RESET ON SWITCH
    selectedRow = null;
    selectedCol = null;
    selectedNumber = null;

    notifyListeners();
  }

  /// ---------- TILE ----------
  void selectTile(int row, int col) {
    int value = board[row][col];

    if (mode == InputMode.fast) {
      /// FAST MODE

      if (value != 0) {
        selectedNumber = value;
        notifyListeners();
        return;
      }

      if (selectedNumber != null) {
        selectedRow = row;
        selectedCol = col;
        inputNumber(selectedNumber!);

        selectedRow = null;
        selectedCol = null;
      }

      return;
    }

    /// STANDARD MODE

    if (value == 0) {
      selectedRow = row;
      selectedCol = col;
      selectedNumber = null;
    } else {
      selectedNumber = value;
      selectedRow = null;
      selectedCol = null;
    }

    notifyListeners();
  }

  /// ---------- NUMBER ----------
  void selectNumber(int number) {
    if (mode == InputMode.fast) {
      selectedNumber = number;
      notifyListeners();
      return;
    }

    if (selectedRow != null && selectedCol != null) {
      inputNumber(number);
    } else {
      selectedNumber = number;
      notifyListeners();
    }
  }

  /// ---------- INPUT ----------
  void inputNumber(int number) {
    if (state != GameState.playing) return;
    if (selectedRow == null || selectedCol == null) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (isGiven[row][col]) return;

    int prev = board[row][col];

    history.add(Move(
      row: row,
      col: col,
      previousValue: prev,
      newValue: number,
      wasPencil: false,
    ));

    redoStack.clear();

    board[row][col] = number;

    if (mode == InputMode.standard) {
      /// After placing → behave like selecting that number
      selectedNumber = number;
    }

    notifyListeners();

    _checkCompletion();

    /// FAST MODE still clears tile selection
    if (mode == InputMode.fast) {
      selectedRow = null;
      selectedCol = null;
    }
  }

  /// ---------- COMPLETION ----------
  void _checkCompletion() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) return;
        if (board[r][c] != solution[r][c]) return;
      }
    }

    state = GameState.completed;
    _timer?.cancel();

    if (onComplete != null && currentDifficulty != null) {
      onComplete!(currentDifficulty!, formattedTime);
    }
  }

  /// ---------- UNDO ----------
  void undo() {
    if (history.isEmpty) return;

    final move = history.removeLast();
    redoStack.add(move);

    board[move.row][move.col] =
        move.previousValue ?? 0;

    /// KEEP TILE SELECTED IN STANDARD MODE
    if (mode == InputMode.standard) {
      selectedRow = move.row;
      selectedCol = move.col;

      int value = board[move.row][move.col];

      if (value == 0) {
        /// tile became empty → clear highlight
        selectedNumber = null;
      } else {
        /// tile still has value → highlight that number
        selectedNumber = value;
      }
    }

    notifyListeners();
  }

  /// ---------- REDO ----------
  void redo() {
    if (redoStack.isEmpty) return;

    final move = redoStack.removeLast();
    history.add(move);

    board[move.row][move.col] =
        move.newValue ?? 0;

    if (mode == InputMode.standard) {
      selectedRow = move.row;
      selectedCol = move.col;

      int value = board[move.row][move.col];

      if (value == 0) {
        /// empty → no highlight
        selectedNumber = null;
      } else {
        /// has number → highlight it
        selectedNumber = value;
      }
    }

    notifyListeners();
  }

  /// ---------- UI HELPERS ----------
  bool isWrong(int row, int col) {
    if (!autoCheck) return false;
    if (isGiven[row][col]) return false;
    if (board[row][col] == 0) return false;

    return board[row][col] != solution[row][col];
  }

  bool shouldHighlight(int row, int col) {
    if (selectedNumber == null) return false;
    return board[row][col] != 0 &&
        board[row][col] == selectedNumber;
  }

  bool isNumberComplete(int number) {
    int count = 0;

    for (var row in board) {
      for (var cell in row) {
        if (cell == number) count++;
      }
    }

    return count >= 9;
  }
}