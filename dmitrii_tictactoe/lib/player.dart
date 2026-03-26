// player.dart
// Barrett Koster 2025

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

/*
  A Player gets called for each of the ServerBase and the ClientBase.
  We establish the game state, usually different depending on 
  whether you are the starting player or not.  
  This establishes the Game and Said BLoC layers. 
*/
class Player extends StatelessWidget
{ final bool iStart;
  Player( this.iStart, {super.key} );

  @override
  Widget build( BuildContext context )
  { 
    return BlocProvider<GameCubit>
    ( create: (context) => GameCubit( iStart ),
      child: BlocBuilder<GameCubit,GameState>
      ( builder: (context,state) => 
        BlocProvider<SaidCubit>
        ( create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit,SaidState>
          ( builder: (context,state) => Scaffold
            ( appBar: AppBar(title: Text("player")),
              body: Player2(),
            ),
          ),
        ),
      ),
    );
  }
}

// this layer initializes the communication.
// By this point, the socets exist in the YakState, but
// they have not yet been told to listen for messages.
class Player2 extends StatelessWidget
{ Widget build( BuildContext context )
  { YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if ( ys.socket != null && !ys.listened )
    { sc.listen(context);
      yc.updateListen();
    } 
    return Player3();
  }
}

// This is the actual presentation of the game.

class Player3 extends StatelessWidget
{ Player3( {super.key} );

  Widget build( BuildContext context )
  { SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    SaidState ss = sc.state;
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    TextEditingController tec = TextEditingController();

    return Column
    ( children:
      [ Text(gs.msg),
        Row(children: [ Sq(0), Sq(1), Sq(2)]),
        Row(children: [ Sq(3), Sq(4), Sq(5)]),
        Row(children: [ Sq(6), Sq(7), Sq(8)]),
        Row
        ( children:
          [ ElevatedButton
            ( onPressed: gs.gameOver ? null :
              ()
              { gc.resign();
                yc.say("resign\n");
              },
              child: Text("resign"),
            ),
            ElevatedButton
            ( onPressed: gs.gameOver ? null :
              ()
              { gc.pass();
                yc.say("pass\n");
              },
              child: Text("pass"),
            ),
          ],
        ),
        Row
        ( children:
          [ SizedBox
            ( width: 220,
              child: TextField( controller: tec ),
            ),
            ElevatedButton
            ( onPressed: ()
              { if ( tec.text.trim() != "" )
                { yc.say("chat ${tec.text}\n");
                  sc.update("me: ${tec.text}");
                  tec.clear();
                }
              },
              child: Text("send"),
            ),
          ],
        ),
        Text("said: ${ss.said}"),
      ]
    );

  }
}

// the squares of the board are just buttons.  You press one 
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget
{ final int sn;
  Sq(this.sn,{super.key});

  Widget build( BuildContext context )
  { GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    // String mark = gs.iStart?"x":"o";

    YakCubit yc = BlocProvider.of<YakCubit>(context);
    
    return ElevatedButton
    ( onPressed: (gs.gameOver || !gs.myTurn || gs.board[sn] != GameCubit.d)
      ? null
      : ()
      { bool ok = gc.play(sn);
        if ( ok ) yc.say("sq $sn\n");
      },
      child: Text(gs.board[sn]),
    );

  }
}