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
  late List<List<Set<int>>> notes;

  List<Move> history = [];
  List<Move> redoStack = [];

  int? selectedRow;
  int? selectedCol;

  int? selectedNumber;
  bool isPencilSelected = false;

  InputMode mode = InputMode.standard;
  bool pencilMode = false;

  bool autoCheck = true;
  bool timerEnabled = true;

  Color penColor = Colors.blue;
  Color backgroundColor = Colors.white;

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

  void pauseTimer() => _timer?.cancel();

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
    penColor = color;
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

  void setBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  } 

  /// ---------- PENCIL ----------
  void togglePencil() {
    pencilMode = !pencilMode;

    if (!pencilMode && isPencilSelected) {
      isPencilSelected = false;
    }

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

    notes = List.generate(
      9,
      (_) => List.generate(9, (_) => <int>{}),
    );

    history.clear();
    redoStack.clear();

    selectedRow = null;
    selectedCol = null;
    selectedNumber = null;
    isPencilSelected = false;

    seconds = 0;
    _startTimer();

    notifyListeners();
  }

  /// ---------- MODE ----------
  void toggleMode() {
    if (mode == InputMode.fast) {
      mode = InputMode.standard;
      selectedRow = null;
      selectedCol = null;
      selectedNumber = null;
      // isPencilSelected = false;
    } else {
      mode = InputMode.fast;
      selectedRow = null;
      selectedCol = null;
      selectedNumber = null;
    }

    notifyListeners();
  }

  /// ---------- TILE ----------
  void selectTile(int row, int col) {
    int value = board[row][col];

    if (mode == InputMode.fast) {
      if (selectedNumber == null) return;

      if (isPencilSelected) {
        _applyNote(row, col, selectedNumber!);
      } else {
        _applyNumber(row, col, selectedNumber!);
      }
      return;
    }

    /// STANDARD MODE

    if (value == 0) {
      /// empty cell → normal select
      selectedRow = row;
      selectedCol = col;

      selectedNumber = null;
      // isPencilSelected = false;
    } else {
      /// filled cell

      selectedNumber = value;
      isPencilSelected = false;

      /// ✅ FIX: allow editing if NOT given
      if (!isGiven[row][col]) {
        selectedRow = row;
        selectedCol = col;
      } else {
        selectedRow = null;
        selectedCol = null;
      }
    }

    notifyListeners();
  }

  /// ---------- PEN SELECT ----------
  void selectNumber(int number) {
    selectedNumber = number;
    isPencilSelected = false;

    if (mode == InputMode.standard &&
        selectedRow != null &&
        selectedCol != null) {
      inputNumber(number);
    }

    notifyListeners();
  }

  /// ---------- PENCIL SELECT ----------
  void selectPencilNumber(int number) {
    if (mode == InputMode.standard) {
      /// ✅ Only apply, no selection
      if (selectedRow != null && selectedCol != null) {
        _applyNote(selectedRow!, selectedCol!, number);
      }
      return;
    }

    /// FAST MODE (unchanged behavior)
    selectedNumber = number;
    isPencilSelected = true;

    notifyListeners();
  }

  /// ---------- APPLY NUMBER (FIXED) ----------
  void _applyNumber(int row, int col, int number) {
    if (isGiven[row][col]) return;
    if (isNumberComplete(number)) return;

    int previous = board[row][col];

    history.add(Move(
      row: row,
      col: col,
      previousValue: previous,
      newValue: number,
      wasPencil: false,
    ));

    redoStack.clear();

    /// ✅ TOGGLE LOGIC
    if (previous == number) {
      board[row][col] = 0; // remove
    } else {
      board[row][col] = number; // replace
      notes[row][col].clear();
      _removeNotesFromPeers(row, col, number);
    }

    notifyListeners();
    _checkCompletion();
  }

  /// ---------- APPLY NOTE ----------
  void _applyNote(int row, int col, int number) {
    if (isGiven[row][col]) return;
    if (board[row][col] != 0) return;

    final previous = {...notes[row][col]};

    if (notes[row][col].contains(number)) {
      notes[row][col].remove(number);
    } else {
      notes[row][col].add(number);
    }

    history.add(Move(
      row: row,
      col: col,
      wasPencil: true,
      previousNotes: previous,
      newNotes: {...notes[row][col]},
    ));

    redoStack.clear();

    notifyListeners();
  }

  /// ---------- STANDARD INPUT (FIXED) ----------
  void inputNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (isNumberComplete(number)) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (isGiven[row][col]) return;

    int previous = board[row][col];

    history.add(Move(
      row: row,
      col: col,
      previousValue: previous,
      newValue: number,
      wasPencil: false,
    ));

    redoStack.clear();

    /// ✅ TOGGLE LOGIC
    if (previous == number) {
      board[row][col] = 0;
    } else {
      board[row][col] = number;
      notes[row][col].clear();
      _removeNotesFromPeers(row, col, number);
    }

    notifyListeners();
    _checkCompletion();
  }

  void _removeNotesFromPeers(int row, int col, int number) {
    for (int i = 0; i < 9; i++) {
      notes[row][i].remove(number);
      notes[i][col].remove(number);
    }

    int br = row - row % 3;
    int bc = col - col % 3;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        notes[br + r][bc + c].remove(number);
      }
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

    if (move.wasPencil) {
      notes[move.row][move.col] = {...?move.previousNotes};
    } else {
      board[move.row][move.col] = move.previousValue ?? 0;
    }

    notifyListeners();
  }

  /// ---------- REDO ----------
  void redo() {
    if (redoStack.isEmpty) return;

    final move = redoStack.removeLast();
    history.add(move);

    if (move.wasPencil) {
      notes[move.row][move.col] = {...?move.newNotes};
    } else {
      board[move.row][move.col] = move.newValue ?? 0;
    }

    notifyListeners();
  }

  /// ---------- HELPERS ----------
  bool isWrong(int row, int col) {
    if (!autoCheck) return false;
    if (isGiven[row][col]) return false;
    if (board[row][col] == 0) return false;

    return board[row][col] != solution[row][col];
  }

  bool shouldHighlight(int row, int col) {
    if (selectedNumber == null) return false;
    return board[row][col] == selectedNumber;
  }

  bool isNumberComplete(int number) {
    int count = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == number &&
            board[r][c] == solution[r][c]) {
          count++;
        }
      }
    }

    return count >= 9;
  }
}