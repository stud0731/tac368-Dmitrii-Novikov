import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'game_state.dart';

// This Cubit controls the whole game
// it stores the board, moves tiles, adds new tiles, and saves the state
class GameCubit extends HydratedCubit<GameState> {
  static const int boardSize = 4;
  final AudioPlayer _player = AudioPlayer();

  GameCubit() : super(_firstState());

  static GameState _firstState() {
    final board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => 0),
    );

    _addNewTile(board);
    _addNewTile(board);

    return GameState(
      board: board,
      score: _scoreBoard(board),
      highScores: const [],
      gameOver: false,
    );
  }

  void resetGame() {
    final newHighScores = _addHighScore(state.highScores, state.score);

    final board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => 0),
    );

    _addNewTile(board);
    _addNewTile(board);

    emit(GameState(
      board: board,
      score: _scoreBoard(board),
      highScores: newHighScores,
      gameOver: false,
    ));
  }

  void moveLeft() {
    _move('left');
  }

  void moveRight() {
    _move('right');
  }

  void moveUp() {
    _move('up');
  }

  void moveDown() {
    _move('down');
  }

  void saveGame() {
    emit(state.copyWith());
  }

  void quitAndReset() {
    resetGame();
  }

  void _move(String direction) {
    if (state.gameOver) {
      return;
    }

    final oldBoard = _copyBoard(state.board);
    List<List<int>> board = _copyBoard(state.board);

    // Move the board in different directions
    if (direction == 'left') {
      for (int row = 0; row < boardSize; row++) {
        board[row] = _mergeLine(board[row]);
      }
    } else if (direction == 'right') {
      for (int row = 0; row < boardSize; row++) {
        board[row] = _mergeLine(board[row].reversed.toList()).reversed.toList();
      }
    } else if (direction == 'up') {
      board = _moveVertical(board, true);
    } else if (direction == 'down') {
      board = _moveVertical(board, false);
    }

    // Add tile after valid move
    if (!_sameBoard(oldBoard, board)) {
      _playSwipeSound();
      _addNewTile(board);
    }

    final newScore = _scoreBoard(board);
    final over = _isGameOver(board);
    final scores = over
        ? _addHighScore(state.highScores, newScore)
        : state.highScores;

    emit(GameState(
      board: board,
      score: newScore,
      highScores: scores,
      gameOver: over,
    ));
  }

  void _playSwipeSound() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/swipe.wav'));
  }

  List<int> _mergeLine(List<int> line) {
    final numbers = line.where((value) => value != 0).toList();
    final result = <int>[];

    int i = 0;

    // Combine matching tiles
    while (i < numbers.length) {
      if (i + 1 < numbers.length && numbers[i] == numbers[i + 1]) {
        result.add(numbers[i] * 2);
        i += 2;
      } else {
        result.add(numbers[i]);
        i++;
      }
    }

    while (result.length < boardSize) {
      result.add(0);
    }

    return result;
  }

  List<List<int>> _moveVertical(List<List<int>> board, bool up) {
    final newBoard = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => 0),
    );

    // Moves each column
    for (int col = 0; col < boardSize; col++) {
      List<int> line = [];

      for (int row = 0; row < boardSize; row++) {
        line.add(board[row][col]);
      }

      if (!up) {
        line = line.reversed.toList();
      }

      line = _mergeLine(line);

      if (!up) {
        line = line.reversed.toList();
      }

      for (int row = 0; row < boardSize; row++) {
        newBoard[row][col] = line[row];
      }
    }

    return newBoard;
  }

  static void _addNewTile(List<List<int>> board) {
    final emptyCells = <List<int>>[];

    // Find empty cells
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] == 0) {
          emptyCells.add([row, col]);
        }
      }
    }

    if (emptyCells.isEmpty) {
      return;
    }

    final random = Random();
    final spot = emptyCells[random.nextInt(emptyCells.length)];
    final newValue = _newTileValue(board);

    board[spot[0]][spot[1]] = newValue;
  }

  static int _newTileValue(List<List<int>> board) {
    final maxTile = _maximumTile(board);

    // what is the new tile value
    if (maxTile < 16) {
      return 1;
    }

    if (maxTile < 64) {
      if (_hasEvenCount(board, 1)) {
        return 2;
      }
      return 1;
    }

    if (maxTile < 256) {
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2)) {
        return 4;
      }
      if (_hasEvenCount(board, 1)) {
        return 2;
      }
      return 1;
    }

    if (maxTile < 1024) {
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4)) {
        return 8;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2)) {
        return 4;
      }
      if (_hasEvenCount(board, 1)) {
        return 2;
      }
      return 1;
    }

    if (maxTile < 4096) {
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8)) {
        return 16;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4)) {
        return 8;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2)) {
        return 4;
      }
      if (_hasEvenCount(board, 1)) {
        return 2;
      }
      return 1;
    }

    if (maxTile < 16384) {
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8) && _hasEvenCount(board, 16)) {
        return 32;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8)) {
        return 16;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4)) {
        return 8;
      }
      if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2)) {
        return 4;
      }
      if (_hasEvenCount(board, 1)) {
        return 2;
      }
      return 1;
    }

    if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8) && _hasEvenCount(board, 16) && _hasEvenCount(board, 32)) {
      return 64;
    }
    if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8) && _hasEvenCount(board, 16)) {
      return 32;
    }
    if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4) && _hasEvenCount(board, 8)) {
      return 16;
    }
    if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2) && _hasEvenCount(board, 4)) {
      return 8;
    }
    if (_hasEvenCount(board, 1) && _hasEvenCount(board, 2)) {
      return 4;
    }
    if (_hasEvenCount(board, 1)) {
      return 2;
    }
    return 1;
  }

  static bool _hasEvenCount(List<List<int>> board, int target) {
    final count = _countTiles(board, target);
    return count % 2 == 0;
  }

  static int _countTiles(List<List<int>> board, int target) {
    int count = 0;

    for (final row in board) {
      for (final value in row) {
        if (value == target) {
          count++;
        }
      }
    }

    return count;
  }

  static int _maximumTile(List<List<int>> board) {
    int maxTile = 0;

    for (final row in board) {
      for (final value in row) {
        if (value > maxTile) {
          maxTile = value;
        }
      }
    }

    return maxTile;
  }

  static int _scoreBoard(List<List<int>> board) {
    int total = 0;

    for (final row in board) {
      for (final value in row) {
        total += value;
      }
    }

    return total;
  }

  bool _isGameOver(List<List<int>> board) {
    for (final row in board) {
      if (row.contains(0)) {
        return false;
      }
    }

    // Check possible merges
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final value = board[row][col];

        if (row + 1 < boardSize && board[row + 1][col] == value) {
          return false;
        }

        if (col + 1 < boardSize && board[row][col + 1] == value) {
          return false;
        }
      }
    }

    return true;
  }

  static List<int> _addHighScore(List<int> oldScores, int newScore) {
    if (newScore == 0) {
      return oldScores;
    }

    final scores = [...oldScores];

    if (!scores.contains(newScore)) {
      scores.add(newScore);
    }

    scores.sort((a, b) => b.compareTo(a));

    if (scores.length > 5) {
      return scores.sublist(0, 5);
    }

    return scores;
  }

  static List<List<int>> _copyBoard(List<List<int>> board) {
    return board.map((row) => [...row]).toList();
  }

  bool _sameBoard(List<List<int>> first, List<List<int>> second) {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (first[row][col] != second[row][col]) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }

  @override
  GameState? fromJson(Map<String, dynamic> json) {
    return GameState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(GameState state) {
    return state.toJson();
  }
}