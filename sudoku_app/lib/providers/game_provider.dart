import 'package:flutter/material.dart';
import '../services/sudoku_generator.dart';
import '../models/move.dart';

enum InputMode { standard, fast }

class GameProvider extends ChangeNotifier {
  late List<List<int>> board;
  late List<List<int>> solution;

  /// Pencil notes per tile
  Map<String, Set<int>> notes = {};

  List<Move> history = [];

  int? selectedRow;
  int? selectedCol;
  int? selectedNumber;

  InputMode mode = InputMode.standard;
  bool pencilMode = false;
  bool showMistakes = true;

  Map<String, Color> colors = {
    "grid": Colors.black,
    "user": Colors.blue,
    "error": Colors.red,
  };

  /// ---------- NEW GAME ----------
  void newGame(Difficulty difficulty) {
    final fullSolution = SudokuGenerator.generateSolved();
    solution = fullSolution.map((row) => [...row]).toList();

    board = SudokuGenerator.createPuzzle(fullSolution, difficulty);

    history.clear();
    notes.clear();

    notifyListeners();
  }

  /// ---------- TILE ----------
  void selectTile(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void selectNumber(int number) {
    selectedNumber = number;
    notifyListeners();
  }

  /// ---------- INPUT ----------
  void inputNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (pencilMode) {
      _handlePencil(row, col, number);
    } else {
      _handleNormal(row, col, number);
    }

    notifyListeners();
  }

  void _handleNormal(int row, int col, int number) {
    int previous = board[row][col];

    history.add(Move(
      row: row,
      col: col,
      previousValue: previous,
      newValue: number,
      wasPencil: false,
    ));

    board[row][col] = number;

    /// clear notes if writing real number
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

    if (last.wasPencil) {
      notes["${last.row}-${last.col}"] =
          last.previousNotes ?? {};
    } else {
      board[last.row][last.col] =
          last.previousValue ?? 0;
    }

    notifyListeners();
  }

  /// ---------- TOGGLES ----------
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