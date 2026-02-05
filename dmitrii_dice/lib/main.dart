// Dmitrii Novikov
// TAC 368 Lab 5: Dice

import "package:flutter/material.dart";
import "dart:math";

void main()
{
  runApp(DiceApp());
}

class DiceApp extends StatelessWidget
{
  DiceApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: "Dmitrii Novikov Dice",
      home: DiceHome(),
    );
  }
}

class DiceHome extends StatefulWidget
{
  @override
  State<DiceHome> createState() => DiceHomeState();
}

class DiceHomeState extends State<DiceHome>
{
  // use random numbers
  Random rng = Random();

  List<int> dice = [1, 1, 1, 1, 1];
  List<bool> hold = [false, false, false, false, false];

  // roll one die
  int rollOne()
  {
    return rng.nextInt(6) + 1; // random numbers from 0 to 5 plus 1
  }

  // roll all dice that are not held
  void rollAll()
  {
    setState(() {
      for (int i = 0; i < 5; i++)
      {
        if (hold[i] == false)
        {
          dice[i] = rollOne();
        }
      }
    });
  }

  // flip the hold switch for one die
  void toggleHold(int i)
  {
    setState(() {
      hold[i] = !hold[i];
    });
  }

  // UI for one die
  Widget dieWidget(int i)
  {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 8),
          ),
          child: Text(
            "${dice[i]}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () { toggleHold(i); },
          child: Text(hold[i] ? "Held" : "Hold"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text("Dmitrii Novikov Dice")),
      body: Column(
        children: [
          const Text(
            "Press the button to roll.\nHold to keep a die the same.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.orange,
            ),
          ),

          Spacer(flex: 1),
          Spacer(flex: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // five dice
              children: [
                dieWidget(0),
                dieWidget(1),
                dieWidget(2),
                dieWidget(3),
                dieWidget(4),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: rollAll,
            child: const Text("Roll"),
          ),

          Spacer(flex: 1),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}