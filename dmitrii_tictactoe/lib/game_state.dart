// game_state.dart
// Barrett Koster 2025

import "package:flutter_bloc/flutter_bloc.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;
  bool gameOver;
  String msg;

  GameState( this.iStart, this.myTurn, this.board, this.gameOver, this.msg );
}

class GameCubit extends Cubit<GameState>
{
  static final String d = ".";
  GameCubit( bool myt ): super( GameState( myt, myt, [d,d,d,d,d,d,d,d,d], false,
    myt ? "your turn" : "opponent's turn" )); 

  update( int where, String what )
  {
    if ( state.gameOver ) return;
    if ( state.board[where] != d ) return;

    state.board[where] = what;
    state.myTurn = !state.myTurn;

    String w = winner();
    if ( w != "" )
    {
      state.gameOver = true;
      if ( w == "draw" ) state.msg = "draw";
      else state.msg = "$w wins";
    }
    else
    {
      state.msg = state.myTurn ? "your turn" : "opponent's turn";
    }

    emit( GameState(state.iStart,state.myTurn,List<String>.from(state.board),
      state.gameOver,state.msg) ) ;
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ... 
  // Update the board and emit.
  play( int where )
  {
    if ( state.gameOver ) return false;
    if ( !state.myTurn ) return false;
    if ( state.board[where] != d ) return false;

    String mark = state.iStart? "x":"o";
    state.board[where] = mark;
    state.myTurn = !state.myTurn;

    String w = winner();
    if ( w != "" )
    {
      state.gameOver = true;
      if ( w == "draw" ) state.msg = "draw";
      else state.msg = "$w wins";
    }
    else
    {
      state.msg = state.myTurn ? "your turn" : "opponent's turn";
    }

    emit( GameState(state.iStart,state.myTurn,List<String>.from(state.board),
      state.gameOver,state.msg) ) ;
    return true;
  }

  String winner()
  {
    List<List<int>> wins =
    [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6]
    ];

    for ( var w in wins )
    {
      String a = state.board[w[0]];
      String b = state.board[w[1]];
      String c = state.board[w[2]];
      if ( a != d && a == b && b == c ) return a;
    }

    bool full = true;
    for ( String s in state.board )
    {
      if ( s == d ) full = false;
    }
    if ( full ) return "draw";

    return "";
  }

  void resign()
  {
    if ( state.gameOver ) return;
    state.gameOver = true;
    state.msg = "you resigned";
    emit( GameState(state.iStart,state.myTurn,List<String>.from(state.board),
      state.gameOver,state.msg) ) ;
  }

  void otherResigned()
  {
    if ( state.gameOver ) return;
    state.gameOver = true;
    state.msg = "opponent resigned";
    emit( GameState(state.iStart,state.myTurn,List<String>.from(state.board),
      state.gameOver,state.msg) ) ;
  }

  void pass()
  {
    if ( state.gameOver ) return;
    state.myTurn = !state.myTurn;
    state.msg = state.myTurn ? "your turn" : "opponent's turn";
    emit( GameState(state.iStart,state.myTurn,List<String>.from(state.board),
      state.gameOver,state.msg) ) ;
  }

  // incoming messages are sent here for the game to do
  // whatever with.  in this case, "sq NUM" messages ..
  // we send the number to be played.
  void handle( String msg )
  {
    List<String> parts = msg.trim().split(" ");
    if ( parts[0] == "sq" )
    {
      int sqNum = int.parse(parts[1]);
      String mark = state.iStart ? "o" : "x";
      update(sqNum, mark);
    }
    else if ( parts[0] == "resign" )
    {
      otherResigned();
    }
    else if ( parts[0] == "pass" )
    {
      pass();
    }
  }
}