import '../models/tile_placement.dart';

class GameState {
  final bool isHost;
  final bool connected;
  final bool gameStarted;
  final String status;
  final bool myTurn;

  final String hostInput;
  final String portInput;

  final List<List<String>> board;
  final List<String> rack;
  final int selectedRackIndex;
  final List<TilePlacement> placedThisTurn;

  final int myScore;
  final int otherScore;
  final List<String> bag;

  GameState({
    required this.isHost,
    required this.connected,
    required this.gameStarted,
    required this.status,
    required this.myTurn,
    required this.hostInput,
    required this.portInput,
    required this.board,
    required this.rack,
    required this.selectedRackIndex,
    required this.placedThisTurn,
    required this.myScore,
    required this.otherScore,
    required this.bag,
  });

  // first state
  factory GameState.initial() {
    return GameState(
      isHost: false,
      connected: false,
      gameStarted: false,
      status: 'Not connected',
      myTurn: false,
      hostInput: 'localhost',
      portInput: '4040',
      board: List.generate(15, (_) => List.filled(15, '')),
      rack: List.filled(7, ''),
      selectedRackIndex: -1,
      placedThisTurn: [],
      myScore: 0,
      otherScore: 0,
      bag: [],
    );
  }

  // state copy
  GameState copyWith({
    bool? isHost,
    bool? connected,
    bool? gameStarted,
    String? status,
    bool? myTurn,
    String? hostInput,
    String? portInput,
    List<List<String>>? board,
    List<String>? rack,
    int? selectedRackIndex,
    List<TilePlacement>? placedThisTurn,
    int? myScore,
    int? otherScore,
    List<String>? bag,
  }) {
    return GameState(
      isHost: isHost ?? this.isHost,
      connected: connected ?? this.connected,
      gameStarted: gameStarted ?? this.gameStarted,
      status: status ?? this.status,
      myTurn: myTurn ?? this.myTurn,
      hostInput: hostInput ?? this.hostInput,
      portInput: portInput ?? this.portInput,
      board: board ?? this.board,
      rack: rack ?? this.rack,
      selectedRackIndex: selectedRackIndex ?? this.selectedRackIndex,
      placedThisTurn: placedThisTurn ?? this.placedThisTurn,
      myScore: myScore ?? this.myScore,
      otherScore: otherScore ?? this.otherScore,
      bag: bag ?? this.bag,
    );
  }
}