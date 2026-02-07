// Dmitrii Novikov
// TAC 368 HW3: Lights Out

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "lights_bloc.dart";

// start the app and make one bloc for the whole app
void main()
{
  runApp(
    BlocProvider(
      create: (_) { return LOBloc(); },
      child: App1(),
    ),
  );
}

class App1 extends StatelessWidget
{
  App1({super.key});

  // main app wrapper
  Widget build(BuildContext context)
  {
    return MaterialApp(
      home: Page1(),
    );
  }
}

class Page1 extends StatelessWidget
{
  Page1({super.key});

  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text("Lights Out - Dmitrii Novikov")),

      // add padding so it looks normal
      body: Padding(
        padding: EdgeInsets.all(16.0),

        // rebuild when the bloc state changes
        child: BlocBuilder<LOBloc, LOState>(
          builder: (context, st)
          {
            // make the light boxes
            List<Widget> boxList = [];
            for (int i = 0; i < st.n; i++)
            {
              bool on = st.lights[i];

              boxList.add(
                // tap sends event to toggle this index
                GestureDetector(
                  onTap: () {
                    context.read<LOBloc>().add(ToggleAt(i));
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3),
                      color: on ? Colors.yellow : Colors.brown,
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // show the lights in a row, scroll if too many
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: boxList),
                ),

                SizedBox(height: 20),

                // buttons to change n and randomize
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<LOBloc>().add(DecLights());
                      },
                      child: Text("-"),
                    ),
                    SizedBox(width: 12),
                    Text("${st.n}", style: TextStyle(fontSize: 22)),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LOBloc>().add(IncLights());
                      },
                      child: Text("+"),
                    ),
                    SizedBox(width: 18),
                    // EXTRA BUTTON TO RESET (makes it more convenient even though
                    // not required by the assignment)
                    ElevatedButton(
                      onPressed: () {
                        context.read<LOBloc>().add(Randomize());
                      },
                      child: Text("randomize"),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // show win message when all lights are off
                if (st.solved())
                  Text("all lights out!", style: TextStyle(fontSize: 22)),
              ],
            );
          },
        ),
      ),
    );
  }
}