// Dmitrii Novikov
// TAC 368 Lab 11: Hydrate Chess

// chess_state.dart
// Barrett Koster 2025

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'coords.dart';

class ChessState
{
  List<List<String>> board;
  int turnCount;

  ChessState() : board=
    [
      ['r.','p',' ',' ',' ',' ','P','R.'],
      ['n','p',' ',' ',' ',' ','P','N'],
      ['b','p',' ',' ',' ',' ','P','B'],
      ['q','p',' ',' ',' ',' ','P','Q'],
      ['k','p',' ',' ',' ',' ','P','K'],
      ['b','p',' ',' ',' ',' ','P','B'],
      ['n','p',' ',' ',' ',' ','P','N'],
      ['r.','p',' ',' ',' ',' ','P','R.'],
    ], turnCount = 0;

  ChessState.load( this.board, this.turnCount );

  Map<String, dynamic> toJson()
  {
    return {
      'board': board,
      'turnCount': turnCount,
      'v': 1,
    };
  }

  factory ChessState.fromJson(Map<String, dynamic> json)
  {
    final rawBoard = (json['board'] as List).map((col) {
      return (col as List).map((sq) => sq as String).toList();
    }).toList();

    final tc = (json['turnCount'] as int?) ?? 0;
    return ChessState.load(rawBoard, tc);
  }
}

class ChessCubit extends HydratedCubit<ChessState>
{
  ChessCubit() : super( ChessState() );

  void update( Coords fromHere, Coords toHere )
  {
    // deep copy to not change the existing state in place
    final newBoard = state.board
      .map((col) => List<String>.from(col))
      .toList();

    newBoard[toHere.c][toHere.r] = newBoard[fromHere.c][fromHere.r];
    newBoard[fromHere.c][fromHere.r] = " ";

    emit( ChessState.load( newBoard, state.turnCount+1) );
  }

  @override
  ChessState? fromJson(Map<String, dynamic> json)
  {
    try { return ChessState.fromJson(json); }
    catch (_) { return null; }
  }

  @override
  Map<String, dynamic>? toJson(ChessState state)
  {
    return state.toJson();
  }
}