import 'package:flutter/material.dart';

import 'game_tile.dart';

// this widget displays the whole game board
// it builds a square grid using current board values
class GameBoard extends StatelessWidget {
  final List<List<int>> board;

  const GameBoard({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    final size = board.length;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          // create board rows
          children: List.generate(size, (row) {
            return Expanded(
              child: Row(
                // create tiles in each row
                children: List.generate(size, (col) {
                  return Expanded(
                    // display one tile
                    child: GameTile(value: board[row][col]),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}