import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tile_placement.dart';
import '../networking/game_connection.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameConnection connection;
  StreamSubscription? _subscription;

  GameBloc(this.connection) : super(GameState.initial()) {
    on<HostPressed>(_onHostPressed);
    on<JoinPressed>(_onJoinPressed);
    on<StartGamePressed>(_onStartGamePressed);
    on<MessageReceived>(_onMessageReceived);
    on<RackTilePressed>(_onRackTilePressed);
    on<BoardCellPressed>(_onBoardCellPressed);
    on<EndTurnPressed>(_onEndTurnPressed);
    on<HostInputChanged>(_onHostInputChanged);
    on<PortInputChanged>(_onPortInputChanged);
  }

  // make bag
  List<String> makeBag() {
    const letters =
        'EEEEEEEEEEEEAAAAAAAAAIIIIIIIIIOOOOOOOONNNNNNRRRRRRTTTTTLLLLSSSSUUUUDDDDGGGBBCCMMPPFFHHVVWWYYKJXQZ';
    List<String> bag = letters.split('');
    bag.shuffle(Random());
    return bag;
  }

  // draw letters
  List<String> drawLetters(List<String> bag, int count) {
    List<String> result = [];
    for (int i = 0; i < count; i++) {
      if (bag.isNotEmpty) {
        result.add(bag.removeLast());
      }
    }
    return result;
  }

  // save host input
  void _onHostInputChanged(HostInputChanged event, Emitter<GameState> emit) {
    emit(state.copyWith(hostInput: event.host));
  }

  // save port input
  void _onPortInputChanged(PortInputChanged event, Emitter<GameState> emit) {
    emit(state.copyWith(portInput: event.port));
  }

  // host logic
  Future<void> _onHostPressed(HostPressed event, Emitter<GameState> emit) async {
    emit(state.copyWith(isHost: true, status: 'Waiting for client...'));

    await connection.host(event.port);
    _subscription = connection.messages.listen((message) {
      add(MessageReceived(message));
    });

    emit(state.copyWith(
      isHost: true,
      connected: true,
      status: 'Client connected',
    ));
  }

  // join logic
  Future<void> _onJoinPressed(JoinPressed event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: 'Connecting...'));

    await connection.join(event.host, event.port);
    _subscription = connection.messages.listen((message) {
      add(MessageReceived(message));
    });

    emit(state.copyWith(
      isHost: false,
      connected: true,
      status: 'Connected to host',
    ));
  }

  // start game
  void _onStartGamePressed(StartGamePressed event, Emitter<GameState> emit) {
    if (!state.isHost || !state.connected) return;

    List<String> bag = makeBag();

    List<String> hostRack = List.filled(7, '');
    List<String> clientRack = List.filled(7, '');

    List<String> hostLetters = drawLetters(bag, 7);
    List<String> clientLetters = drawLetters(bag, 7);

    for (int i = 0; i < hostLetters.length; i++) {
      hostRack[i] = hostLetters[i];
    }

    for (int i = 0; i < clientLetters.length; i++) {
      clientRack[i] = clientLetters[i];
    }

    connection.send({
      'type': 'start',
      'rack': clientRack,
      'board': state.board,
      'myTurn': false,
    });

    emit(state.copyWith(
      gameStarted: true,
      status: 'Your turn',
      myTurn: true,
      rack: hostRack,
      bag: bag,
      selectedRackIndex: -1,
      placedThisTurn: [],
      myScore: 0,
      otherScore: 0,
    ));
  }

  // select rack
  void _onRackTilePressed(RackTilePressed event, Emitter<GameState> emit) {
    if (!state.myTurn) return;
    if (state.rack[event.index].isEmpty) return;

    emit(state.copyWith(selectedRackIndex: event.index));
  }

  // place tile
  void _onBoardCellPressed(BoardCellPressed event, Emitter<GameState> emit) {
    if (!state.myTurn) return;
    if (state.selectedRackIndex == -1) return;
    if (state.board[event.row][event.col].isNotEmpty) return;

    List<List<String>> newBoard =
        state.board.map((row) => List<String>.from(row)).toList();
    List<String> newRack = List<String>.from(state.rack);
    List<TilePlacement> newPlaced = List<TilePlacement>.from(state.placedThisTurn);

    String letter = newRack[state.selectedRackIndex];
    newBoard[event.row][event.col] = letter;
    newRack[state.selectedRackIndex] = '';

    newPlaced.add(TilePlacement(
      row: event.row,
      col: event.col,
      letter: letter,
    ));

    emit(state.copyWith(
      board: newBoard,
      rack: newRack,
      placedThisTurn: newPlaced,
      selectedRackIndex: -1,
    ));
  }

  // finish turn
  void _onEndTurnPressed(EndTurnPressed event, Emitter<GameState> emit) {
    if (!state.myTurn) return;
    if (state.placedThisTurn.isEmpty) return;

    if (state.isHost) {
      List<String> newBag = List<String>.from(state.bag);
      List<String> newRack = List<String>.from(state.rack);

      for (int i = 0; i < newRack.length; i++) {
        if (newRack[i].isEmpty && newBag.isNotEmpty) {
          newRack[i] = newBag.removeLast();
        }
      }

      connection.send({
        'type': 'hostPlayed',
        'placements': state.placedThisTurn.map((p) => p.toJson()).toList(),
      });

      emit(state.copyWith(
        rack: newRack,
        bag: newBag,
        myTurn: false,
        status: 'Opponent turn',
        myScore: state.myScore + state.placedThisTurn.length,
        placedThisTurn: [],
      ));
    } else {
      connection.send({
        'type': 'clientPlayed',
        'placements': state.placedThisTurn.map((p) => p.toJson()).toList(),
      });

      emit(state.copyWith(
        myTurn: false,
        status: 'Opponent turn',
        myScore: state.myScore + state.placedThisTurn.length,
        placedThisTurn: [],
      ));
    }
  }

  // handle messages
  void _onMessageReceived(MessageReceived event, Emitter<GameState> emit) {
    Map<String, dynamic> msg = event.message;

    if (msg['type'] == 'start') {
      List<List<String>> newBoard = (msg['board'] as List)
          .map((row) => List<String>.from(row))
          .toList();

      emit(state.copyWith(
        gameStarted: true,
        rack: List<String>.from(msg['rack']),
        board: newBoard,
        myTurn: msg['myTurn'],
        status: msg['myTurn'] ? 'Your turn' : 'Opponent turn',
        myScore: 0,
        otherScore: 0,
      ));
    } else if (msg['type'] == 'hostPlayed') {
      List<TilePlacement> placements = (msg['placements'] as List)
          .map((e) => TilePlacement.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      List<List<String>> newBoard =
          state.board.map((row) => List<String>.from(row)).toList();

      for (TilePlacement p in placements) {
        newBoard[p.row][p.col] = p.letter;
      }

      emit(state.copyWith(
        board: newBoard,
        otherScore: state.otherScore + placements.length,
        myTurn: true,
        status: 'Your turn',
      ));
    } else if (msg['type'] == 'clientPlayed' && state.isHost) {
      List<TilePlacement> placements = (msg['placements'] as List)
          .map((e) => TilePlacement.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      List<List<String>> newBoard =
          state.board.map((row) => List<String>.from(row)).toList();

      for (TilePlacement p in placements) {
        newBoard[p.row][p.col] = p.letter;
      }

      List<String> newBag = List<String>.from(state.bag);
      List<String> clientRack = List.filled(7, '');
      List<String> letters = drawLetters(newBag, 7);

      for (int i = 0; i < letters.length; i++) {
        clientRack[i] = letters[i];
      }

      connection.send({
        'type': 'clientNewRack',
        'rack': clientRack,
      });

      connection.send({
        'type': 'showClientMove',
        'placements': msg['placements'],
      });

      emit(state.copyWith(
        board: newBoard,
        bag: newBag,
        otherScore: state.otherScore + placements.length,
        myTurn: true,
        status: 'Your turn',
      ));
    } else if (msg['type'] == 'clientNewRack') {
      emit(state.copyWith(rack: List<String>.from(msg['rack'])));
    } else if (msg['type'] == 'showClientMove') {
      List<TilePlacement> placements = (msg['placements'] as List)
          .map((e) => TilePlacement.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      List<List<String>> newBoard =
          state.board.map((row) => List<String>.from(row)).toList();

      for (TilePlacement p in placements) {
        newBoard[p.row][p.col] = p.letter;
      }

      emit(state.copyWith(board: newBoard));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await connection.close();
    return super.close();
  }
}