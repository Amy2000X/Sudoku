class Move {
  final int row;
  final int col;

  final int? previousValue;
  final int? newValue;

  final bool wasPencil;
  final Set<int>? previousNotes;
  final Set<int>? newNotes;

  Move({
    required this.row,
    required this.col,
    this.previousValue,
    this.newValue,
    required this.wasPencil,
    this.previousNotes,
    this.newNotes,
  });
}