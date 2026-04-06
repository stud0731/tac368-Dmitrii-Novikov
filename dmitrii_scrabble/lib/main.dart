import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/game_bloc.dart';
import 'bloc/game_event.dart';
import 'bloc/game_state.dart';
import 'networking/game_connection.dart';

void main() {
  runApp(const MyApp());
}

// app root
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        // create bloc
        create: (_) => GameBloc(GameConnection()),
        child: const GameScreen(),
      ),
    );
  }
}

// main screen
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dmitrii Scrabble')),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // top controls
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        initialValue: state.hostInput,
                        decoration: const InputDecoration(
                          labelText: 'Host IP',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          context.read<GameBloc>().add(HostInputChanged(value));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: state.portInput,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          context.read<GameBloc>().add(PortInputChanged(value));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // host game
                    ElevatedButton(
                      onPressed: state.connected
                          ? null
                          : () {
                              context.read<GameBloc>().add(
                                    HostPressed(int.tryParse(state.portInput) ?? 4040),
                                  );
                            },
                      child: const Text('Host'),
                    ),
                    const SizedBox(width: 8),

                    // join game
                    ElevatedButton(
                      onPressed: state.connected
                          ? null
                          : () {
                              context.read<GameBloc>().add(
                                    JoinPressed(
                                      state.hostInput.trim(),
                                      int.tryParse(state.portInput) ?? 4040,
                                    ),
                                  );
                            },
                      child: const Text('Join'),
                    ),
                    const SizedBox(width: 8),

                    // start game
                    ElevatedButton(
                      onPressed: state.isHost && state.connected && !state.gameStarted
                          ? () {
                              context.read<GameBloc>().add(StartGamePressed());
                            }
                          : null,
                      child: const Text('Start Game'),
                    ),
                    const SizedBox(width: 8),

                    // end turn
                    ElevatedButton(
                      onPressed: state.gameStarted && state.myTurn
                          ? () {
                              context.read<GameBloc>().add(EndTurnPressed());
                            }
                          : null,
                      child: const Text('End Turn'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // status text
                Text(
                  state.status,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // score text
                Text('My score: ${state.myScore}   Opponent score: ${state.otherScore}'),
                const SizedBox(height: 12),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AspectRatio(
                          aspectRatio: 1,

                          // game board
                          child: GridView.builder(
                            itemCount: 15 * 15,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 15,
                            ),
                            itemBuilder: (context, index) {
                              int row = index ~/ 15;
                              int col = index % 15;
                              String letter = state.board[row][col];

                              return GestureDetector(
                                // place tile
                                onTap: () {
                                  context.read<GameBloc>().add(BoardCellPressed(row, col));
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: letter.isEmpty
                                        ? Colors.blue.shade50
                                        : Colors.green.shade200,
                                    border: Border.all(color: Colors.black26),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Rack',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // player rack
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(state.rack.length, (index) {
                                String letter = state.rack[index];
                                bool selected = state.selectedRackIndex == index;

                                return GestureDetector(
                                  // select tile
                                  onTap: () {
                                    context.read<GameBloc>().add(RackTilePressed(index));
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: letter.isEmpty
                                          ? Colors.grey.shade300
                                          : Colors.amber.shade200,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: selected ? 3 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),

                            // instructions
                            const Text('Click tile, then square.'),
                            const SizedBox(height: 8),
                            const Text('Board is shared. Rack is private.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}