import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dmitrii_2048_project/l10n/app_localizations.dart';

import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../cubit/locale_cubit.dart';
import '../widgets/game_board.dart';

// display the main game page
// handle score, board, controls, language buttons, and quit dialog
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(text.appTitle),
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleCubit>().setEnglish(),
            child: Text(text.english),
          ),
          TextButton(
            onPressed: () => context.read<LocaleCubit>().setSpanish(),
            child: Text(text.spanish),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        // Handle keyboard moves
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final game = context.read<GameCubit>();

            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              game.moveLeft();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              game.moveRight();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              game.moveUp();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              game.moveDown();
              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: BlocBuilder<GameCubit, GameState>(
          // Rebuild when game state changes
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // should be of the right size
                final boardSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight * 0.55;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${text.score}: ${state.score}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        _highScores(text, state.highScores),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: boardSize,
                            height: boardSize,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              // Handle swipe moves
                              onPanEnd: (details) {
                                final dx = details.velocity.pixelsPerSecond.dx;
                                final dy = details.velocity.pixelsPerSecond.dy;
                                if (dx.abs() < 100 && dy.abs() < 100) {
                                  return;
                                }
                                if (dx.abs() > dy.abs()) {
                                  if (dx > 0) {
                                    context.read<GameCubit>().moveRight();
                                  } else {
                                    context.read<GameCubit>().moveLeft();
                                  }
                                } else {
                                  if (dy > 0) {
                                    context.read<GameCubit>().moveDown();
                                  } else {
                                    context.read<GameCubit>().moveUp();
                                  }
                                }
                              },
                              child: GameBoard(board: state.board),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.gameOver)
                          Text(
                            text.gameOver,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<GameCubit>().resetGame();
                                },
                                child: Text(text.reset),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showQuitDialog(context, text);
                                },
                                child: Text(text.quit),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _highScores(AppLocalizations text, List<int> scores) {
    final displayScores = scores.isEmpty ? '---' : scores.join(', ');

    return Text(
      '${text.highScores}: $displayScores',
      style: const TextStyle(fontSize: 16),
    );
  }

  void _showQuitDialog(BuildContext context, AppLocalizations text) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(text.quit),
          content: Text(text.quitMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<GameCubit>().saveGame();

                // Show save message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(text.gameSaved),
                  ),
                );
              },
              child: Text(text.save),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<GameCubit>().quitAndReset();
              },
              child: Text(text.reset),
            ),
          ],
        );
      },
    );
  }
}