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

  /// ---------- INPUT ----------
  void selectTile(int row, int col) {
    selectedRow = row;
    selectedCol = col;

    if (mode == InputMode.fast && selectedNumber != null) {
      inputNumber(selectedNumber!);
    }

    notifyListeners();
  }

  void selectNumber(int number) {
    selectedNumber = number;
    notifyListeners();
  }

  void inputNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (isGiven[row][col]) return;

    redoStack.clear(); // important

    if (pencilMode) {
      _handlePencil(row, col, number);
    } else {
      _handleNormal(row, col, number);
    }

    notifyListeners();
  }

  void _handleNormal(int row, int col, int number) {
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
  }

  void _handlePencil(int row, int col, int number) {
    String key = "$row-$col";
    Set<int> current = notes[key] ?? {};

    Set<int> newSet = Set.from(current);

    if (newSet.contains(number)) {
      newSet.remove(number);
    } else {
      newSet.add(number);
    }

    history.add(Move(
      row: row,
      col: col,
      wasPencil: true,
      previousNotes: Set.from(current),
      newNotes: Set.from(newSet),
    ));

    notes[key] = newSet;
  }

  /// ---------- UNDO ----------
  void undo() {
    if (history.isEmpty) return;

    Move last = history.removeLast();
    redoStack.add(last);

    if (last.wasPencil) {
      notes["${last.row}-${last.col}"] =
          last.previousNotes ?? {};
    } else {
      board[last.row][last.col] =
          last.previousValue ?? 0;
    }

    notifyListeners();
  }

  /// ---------- REDO ----------
  void redo() {
    if (redoStack.isEmpty) return;

    Move move = redoStack.removeLast();
    history.add(move);

    if (move.wasPencil) {
      notes["${move.row}-${move.col}"] =
          move.newNotes ?? {};
    } else {
      board[move.row][move.col] =
          move.newValue ?? 0;
    }

    notifyListeners();
  }

  /// ---------- CHECK ----------
  bool isWrong(int row, int col) {
    if (!autoCheck) return false;
    if (isGiven[row][col]) return false;
    if (board[row][col] == 0) return false;

    return board[row][col] != solution[row][col];
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