// Dmitrii Novikov
// TAC 368 Lab 7: Sized Grid

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "sg_bloc.dart";

// provide the SGBloc once so the whole widget structure can use it
void main()
{
  runApp(
    BlocProvider(
      create: (_) { return SGBloc(); },
      child: SG(),
    ),
  );
}

class SG extends StatelessWidget
{
  SG({super.key});

  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: "sized grid",
      home: SG1(),
    );
  }
}

class SG1 extends StatelessWidget
{
  SG1({super.key});

  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text("Dmitrii Novikov Sized Grid")),
      body: Column(
        children: [
          // rebuild this section when width/height changes in the Bloc state
          BlocBuilder<SGBloc, SGState>(
            builder: (context, state)
            {
              int w = state.width;
              int h = state.height;

              // build the grid itself: each column is a column of boxes,
              // the row puts those columns next to each other
              List<Widget> cols = [];
              int i = 0;
              while (i < w)
              {
                List<Widget> boxes = [];
                for (int j = 0; j < h; j++)
                {
                  boxes.add(Boxy(40, 40));
                }
                cols.add(Column(children: boxes));
                i++;
              }

              Row gridRow = Row(children: cols);

              return Column(
                children: [
                  Text("width = $w, height = $h"),

                  // buttons share events with SGBloc
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("width: "),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          context.read<SGBloc>().add(DecWidth());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          context.read<SGBloc>().add(IncWidth());
                        },
                      ),

                      SizedBox(width: 24),

                      Text("height: "),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          context.read<SGBloc>().add(DecHeight());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          context.read<SGBloc>().add(IncHeight());
                        },
                      ),
                    ],
                  ),

                  gridRow,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class Boxy extends Padding
{
  final double width;
  final double height;

  Boxy(this.width, this.height)
    : super(
        padding: EdgeInsets.all(4.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(border: Border.all()),
          child: Text("x"),
        ),
      );
}