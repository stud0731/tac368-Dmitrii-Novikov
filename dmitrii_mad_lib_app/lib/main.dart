// Dmitrii Novikov
// TAC 368 Lab 10: Mad Lib (Version 1)

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "madlib_bloc.dart";

// provide the madlib bloc one time so the whole widget structure can use it
void main()
{
  runApp(
    BlocProvider(
      create: (_) { return MadlibBloc(); },
      child: MadlibApp(),
    ),
  );
}

class MadlibApp extends StatelessWidget
{
  MadlibApp({super.key});

  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "madlib",
      home: MadlibPage(),
    );
  }
}

class MadlibPage extends StatelessWidget
{
  MadlibPage({super.key});

  final TextEditingController animalCtrl = TextEditingController();
  final TextEditingController placeCtrl  = TextEditingController();
  final TextEditingController numberCtrl = TextEditingController();
  final TextEditingController thingCtrl  = TextEditingController();

  Widget field(BuildContext context, String label, String hint, TextEditingController ctrl, String fieldName,
      {TextInputType keyboard = TextInputType.text})
  {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
        onChanged: (s) {
          context.read<MadlibBloc>().add(UpdateField(fieldName, s));
        },
        onSubmitted: (_) {
          context.read<MadlibBloc>().add(UpdateField(fieldName, ctrl.text));
        },
      ),
    );
  }

  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dmitrii Novikov Mad Lib"),
        actions: [
          IconButton(
            tooltip: "clear",
            icon: Icon(Icons.clear),
            onPressed: () {
              animalCtrl.clear();
              placeCtrl.clear();
              numberCtrl.clear();
              thingCtrl.clear();

              context.read<MadlibBloc>().add(UpdateField("animal", ""));
              context.read<MadlibBloc>().add(UpdateField("place", ""));
              context.read<MadlibBloc>().add(UpdateField("number", ""));
              context.read<MadlibBloc>().add(UpdateField("thing", ""));
              context.read<MadlibBloc>().add(ClearStory());
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            field(context, "Choose an animal", "e.g., dog", animalCtrl, "animal"),
            field(context, "Choose a place", "e.g., Los Angeles", placeCtrl, "place"),
            field(context, "Enter a number", "e.g., 1", numberCtrl, "number", keyboard: TextInputType.number),
            field(context, "Name a thing", "e.g., ball", thingCtrl, "thing"),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<MadlibBloc>().add(GenerateStory());
                },
                child: Text("Show Story"),
              ),
            ),

            SizedBox(height: 12),

            Expanded(
              child: BlocBuilder<MadlibBloc, MadlibState>(
                builder: (context, state)
                {
                  if (state.story.length == 0)
                  {
                    return Center(child: Text("the story will appear here"));
                  }

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        child: Text(
                          state.story,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // the status
            BlocBuilder<MadlibBloc, MadlibState>(
              builder: (context, state)
              {
                return Text(state.lastMsg);
              },
            ),
          ],
        ),
      ),
    );
  }
}