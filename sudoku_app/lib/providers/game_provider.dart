import 'package:flutter/material.dart';
import '../services/sudoku_generator.dart';
import '../models/move.dart';

enum InputMode { standard, fast }

class GameProvider extends ChangeNotifier {
  late List<List<int>> board;
  late List<List<int>> solution;
  late List<List<bool>> isGiven;

  Map<String, Set<int>> notes = {};

  List<Move> history = [];
  List<Move> redoStack = [];

  int? selectedRow;
  int? selectedCol;
  int? selectedNumber;

  InputMode mode = InputMode.standard;
  bool pencilMode = false;

  bool autoCheck = true;
  Color userColor = Colors.blue;

  /// ---------- NEW GAME ----------
  void newGame(Difficulty difficulty) {
    final full = SudokuGenerator.generateSolved();

    solution = full.map((r) => [...r]).toList();
    board = SudokuGenerator.createPuzzle(full, difficulty);

    isGiven = List.generate(
      9,
      (r) => List.generate(9, (c) => board[r][c] != 0),
    );

    history.clear();
    redoStack.clear();
    notes.clear();

    selectedRow = null;
    selectedCol = null;
    selectedNumber = null;

    notifyListeners();
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

  /// ---------- TILE ----------
  void selectTile(int row, int col) {
    selectedRow = row;
    selectedCol = col;

    int value = board[row][col];

    /// FAST MODE LOGIC
    if (mode == InputMode.fast) {
      if (value != 0) {
        /// Tap existing number → select it
        selectedNumber = value;
      } else if (selectedNumber != null) {
        /// Empty tile → fill with selected number
        inputNumber(selectedNumber!);
      }
    }

    notifyListeners();
  }

  /// ---------- NUMBER ----------
  void selectNumber(int number) {
    selectedNumber = number;

    /// In standard mode → input immediately
    if (mode == InputMode.standard) {
      inputNumber(number);
    }

    notifyListeners();
  }

  /// ---------- INPUT ----------
  void inputNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (isGiven[row][col]) return;

    redoStack.clear();

    int prev = board[row][col];

    history.add(Move(
      row: row,
      col: col,
      previousValue: prev,
      newValue: number,
      wasPencil: false,
    ));

    board[row][col] = number;
    notes.remove("$row-$col");

    notifyListeners();
  }

  /// ---------- UNDO ----------
  void undo() {
    if (history.isEmpty) return;

    Move last = history.removeLast();
    redoStack.add(last);

    board[last.row][last.col] =
        last.previousValue ?? 0;

    notifyListeners();
  }

  /// ---------- REDO ----------
  void redo() {
    if (redoStack.isEmpty) return;

    Move move = redoStack.removeLast();
    history.add(move);

    board[move.row][move.col] =
        move.newValue ?? 0;

    notifyListeners();
  }

  /// ---------- CHECK ----------
  bool isWrong(int row, int col) {
    if (!autoCheck) return false;
    if (isGiven[row][col]) return false;
    if (board[row][col] == 0) return false;

    return board[row][col] != solution[row][col];
  }

  /// ---------- HIGHLIGHT ----------
  // bool shouldHighlight(int row, int col) {
  //   if (selectedNumber == null) return false;
  //   return board[row][col] == selectedNumber;
  // }
  bool shouldHighlight(int row, int col) {
  if (selectedNumber == null) return false;
  return board[row][col] != 0 &&
      board[row][col] == selectedNumber;
}

  /// ---------- MODES ----------
  void toggleMode() {
    mode =
        mode == InputMode.standard ? InputMode.fast : InputMode.standard;
    notifyListeners();
  }

  void togglePencil() {
    pencilMode = !pencilMode;
    notifyListeners();
  }
}