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

  Map<String, Set<int>> notes = {};

  List<Move> history = [];
  List<Move> redoStack = [];

  int? selectedRow;
  int? selectedCol;
  int? selectedNumber;

  InputMode mode = InputMode.standard;
  bool pencilMode = false;

  bool autoCheck = true;

  /// SETTINGS
  bool timerEnabled = true;

  Color userColor = Colors.blue;

  /// TIMER
  Timer? _timer;
  int seconds = 0;

  /// STATE
  GameState state = GameState.playing;
  Difficulty? currentDifficulty;

  Function(Difficulty diff, String time)? onComplete;

  /// ---------- TIMER CORE ----------
  void _startTimer() {
    _timer?.cancel();

    if (!timerEnabled) return;

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      seconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void pauseTimer() {
    _timer?.cancel();
    state = GameState.paused;
    notifyListeners();
  }

  void resumeTimer() {
    if (state == GameState.completed) return;

    state = GameState.playing;

    if (timerEnabled) {
      _startTimer();
    }

    notifyListeners();
  }

  String get formattedTime {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void toggleTimer(bool value) {
    timerEnabled = value;

    /// IMPORTANT:
    /// keep running in background, just hide UI
    if (timerEnabled && state == GameState.playing) {
      _startTimer();
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

    history.clear();
    redoStack.clear();
    notes.clear();

    selectedRow = null;
    selectedCol = null;
    selectedNumber = null;

    seconds = 0;

    _startTimer();

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

    if (mode == InputMode.standard) {
      inputNumber(number);
    }

    notifyListeners();
  }

  void inputNumber(int number) {
    if (state != GameState.playing) return;
    if (selectedRow == null || selectedCol == null) return;

    int row = selectedRow!;
    int col = selectedCol!;

    if (isGiven[row][col]) return;

    redoStack.clear();

    board[row][col] = number;

    history.add(Move(
      row: row,
      col: col,
      previousValue: 0,
      newValue: number,
      wasPencil: false,
    ));

    notifyListeners();

    _checkCompletion();
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
    _stopTimer();

    final diff = currentDifficulty;
    final time = formattedTime;

    if (onComplete != null && diff != null) {
      onComplete!(diff, time);
    }
  }

  /// ---------- UNDO ----------
  void undo() {
    if (history.isEmpty) return;

    final last = history.removeLast();
    redoStack.add(last);

    board[last.row][last.col] = last.previousValue ?? 0;

    notifyListeners();
  }

  /// ---------- REDO ----------
  void redo() {
    if (redoStack.isEmpty) return;

    final move = redoStack.removeLast();
    history.add(move);

    board[move.row][move.col] = move.newValue ?? 0;

    notifyListeners();
  }

  /// ---------- CHECK ----------
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