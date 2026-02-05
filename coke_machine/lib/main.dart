// Dmitrii Novikov
// TAC 368 Lab 4: Coke Machine

import "package:flutter/material.dart";

void main()
{ runApp(Boggle()); }

// This does ONE board of letters.
class Boggle extends StatelessWidget
{
  List<String> letters; // 25 tiles that make the board
  Boggle({super.key}) : letters = makeCans();

  @override
  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "Lab 4: Coke Machine (Dmitrii Novikov)",
      home: BoggleHome( letters ),
    );
  }
}

// return a list of 25 coordinate labels: A0..E4
List<String> makeCans()
{
  List<String> cols = ["A","B","C","D","E"];
  List<String> cans = [];
  for ( int row=0; row<5; row++ )
  { for ( int col=0; col<5; col++ )
    { cans.add("${cols[col]}$row");
    }
  }
  return cans;
}

class BoggleHome extends StatefulWidget
{
  final List<String> letters; // given in constructor

  BoggleHome( this.letters );

  @override
  State<BoggleHome> createState() => BoggleHomeState( letters );
}

class BoggleHomeState extends State<BoggleHome>
{
  List<String> letters;
  BoggleHomeState(this.letters);

  String word = ""; // selected coordinate
  List<String> words = []; // list of bought coordinates

  FaceUpState? selected; // currently selected tile

  Widget build( BuildContext context )
  { int i=0;

    // build the grid fresh every time
    Column faces = Column(children:<Row>[]);

    for ( int row=0; row<5; row++ )
    { Row r = Row(children:[]);
      for ( int col=0; col<5; col++ )
      {
        FaceUp fup = FaceUp(letters[i], bhs:this );
        r.children.add( fup );
        i++;
      }
      faces.children.add(r);
    }

    return Scaffold
    ( appBar: AppBar( title: Text("Lab 4: Coke Machine (Dmitrii Novikov)") ),
      body: Column
      ( children:
        [ faces,

        FloatingActionButton
        ( onPressed: ()
          { setState
            ( ()
              { if ( selected != null )
                { selected!.buy();
                  words.add(word);
                  word="";
                  selected=null;
                }
              }
            );
          },
          child: Text("buy",style:TextStyle(fontSize:20),),
        ),
        Text("selected=$word"),
        Text("bought=$words"),
        ],
      ),
    );
  }
}

class FaceUp extends StatefulWidget
{
  String show; // coordinates like "A1"
  BoggleHomeState bhs;
  FaceUpState? fus;

  FaceUp( this.show, {required this.bhs} );

  State<FaceUp> createState() => (fus=FaceUpState(show, bhs:bhs));
}

class FaceUpState extends State<FaceUp>
{
  String show;
  BoggleHomeState bhs;
  bool picked = false;
  bool bought = false;

  FaceUpState(this.show, {required this.bhs});

  void reset() { setState((){ picked = false; }); }

  void buy() { setState((){ bought = true; picked = false; }); }

  @override
  Widget build(BuildContext context )
  { return Listener
    ( onPointerDown: (_)
      {
        if (bought) return;

        // unhighlight previously selected tile
        if (bhs.selected != null && bhs.selected != this) {
          bhs.selected!.reset();
        }

        setState(() { picked = true; });

        bhs.setState(() {
          bhs.word = show;
          bhs.selected = this;
        });
      },
      child: bought
        ? SizedBox(height: 50, width: 50)
        : Container
          ( height: 50, width: 50,
            decoration: BoxDecoration
            ( border: Border.all
              ( width:2,
                color: picked? Color(0xff000000): Color(0xff00ff00),
              ),
            ),
            child: Center(
              child: Text(show, style: TextStyle(fontSize: 18)),
            ),
          ),
    );
  }
}