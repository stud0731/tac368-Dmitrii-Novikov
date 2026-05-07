import 'package:flutter/material.dart';

// this widget displays one tile on the board
// also controls the tile color, text, and animation
class GameTile extends StatelessWidget {
  final int value;

  const GameTile({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      // animation
      scale: value == 0 ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // tile color by value
          color: _tileColor(value),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            // empty cells = no text
            value == 0 ? '' : '$value',
            style: TextStyle(
              fontSize: value >= 1024 ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _tileColor(int value) {
    if (value == 0) {
      return Colors.grey.shade300;
    }
    if (value == 1) {
      return Colors.blue.shade100;
    }
    if (value == 2) {
      return Colors.green.shade100;
    }
    if (value == 4) {
      return Colors.yellow.shade200;
    }
    if (value == 8) {
      return Colors.orange.shade200;
    }
    if (value == 16) {
      return Colors.deepOrange.shade200;
    }
    if (value == 32) {
      return Colors.red.shade200;
    }
    if (value == 64) {
      return Colors.purple.shade200;
    }
    return Colors.pink.shade100;
  }
}