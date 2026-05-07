// This class stores all data from the game
// I converted it to JSON so HydratedBloc can save it
class GameState {
  final List<List<int>> board;
  final int score;
  final List<int> highScores;
  final bool gameOver;

  const GameState({
    required this.board,
    required this.score,
    required this.highScores,
    required this.gameOver,
  });

  GameState copyWith({
    List<List<int>>? board,
    int? score,
    List<int>? highScores,
    bool? gameOver,
  }) 
  {
    // Creates updated state
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      highScores: highScores ?? this.highScores,
      gameOver: gameOver ?? this.gameOver,
    );
  }

  Map<String, dynamic> toJson() {
    // Saves state as JSON
    return {
      'board': board,
      'score': score,
      'highScores': highScores,
      'gameOver': gameOver,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List;

    // Loads saved board
    final loadedBoard = boardData.map((row) {
      return (row as List).map((value) => value as int).toList();
    }).toList();

    final scoresData = json['highScores'] as List;

    // Loads saved state
    return GameState(
      board: loadedBoard,
      score: json['score'] as int,
      highScores: scoresData.map((value) => value as int).toList(),
      gameOver: json['gameOver'] as bool,
    );
  }
}