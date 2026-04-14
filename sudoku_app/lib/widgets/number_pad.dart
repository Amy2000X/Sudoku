import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Column(
      children: [
        _buildPenRow(game),
        if (game.pencilMode) _buildPencilRow(game),
      ],
    );
  }

  /// 🔢 PEN ROW
  Widget _buildPenRow(GameProvider game) {
    return Row(
      children: List.generate(9, (index) {
        int number = index + 1;

        bool isSelected =
            !game.isPencilSelected &&
            game.selectedNumber == number &&
            game.mode == InputMode.fast;

        bool isComplete = game.isNumberComplete(number);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AspectRatio(
              aspectRatio: 0.9,
              child: Opacity(
                opacity: isComplete ? 0.0 : 1.0,
                child: _NumberButton(
                  number: number,
                  isSelected: isSelected,
                  color: game.penColor,
                  onTap: () => game.selectNumber(number),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// ✏️ PENCIL ROW
  Widget _buildPencilRow(GameProvider game) {
    return Row(
      children: List.generate(9, (index) {
        int number = index + 1;

        bool isSelected =
            game.isPencilSelected &&
            game.selectedNumber == number;

        bool isComplete = game.isNumberComplete(number);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AspectRatio(
              aspectRatio: 0.9,
              child: Opacity(
                opacity: isComplete ? 0.0 : 1.0,
                child: _PencilButton(
                  number: number,
                  isSelected: isSelected,
                  onTap: () => game.selectPencilNumber(number),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// 🔥 CUSTOM NUMBER BUTTON (NO MATERIAL ISSUES)
class _NumberButton extends StatefulWidget {
  final int number;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;

    if (_isPressed) {
      /// 🔥 pressed = darker
      bgColor = widget.color.withValues(alpha: 0.35);
    } else if (widget.isSelected) {
      /// 🔥 selected (fast mode)
      bgColor = widget.color.withValues(alpha: 0.25);
    } else {
      /// default
      bgColor = widget.color.withValues(alpha: 0.10);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.number.toString(),
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// ✏️ PENCIL BUTTON
class _PencilButton extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const _PencilButton({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}