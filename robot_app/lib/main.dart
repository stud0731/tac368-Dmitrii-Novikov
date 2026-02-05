// Dmitrii Novikov
// TAC 368 HW2: Robot
// Move a robot inside a 5x5 grid using buttons

import "package:flutter/material.dart";

void main() => runApp(Robot());

// App wrapper
class Robot extends StatelessWidget {
  final int gridSize = 5;

  Robot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HW 2: Robot (Dmitrii Novikov)",
      home: RobotHome(gridSize),
    );
  }
}

// Stateful = robot position changes
class RobotHome extends StatefulWidget {
  final int gridSize;

  RobotHome(this.gridSize, {super.key});

  @override
  State<RobotHome> createState() => RobotHomeState(gridSize);
}

class RobotHomeState extends State<RobotHome> {
  int gridSize;

  // Robot coords (row, col)
  int rRow = 0;
  int rCol = 0;

  RobotHomeState(this.gridSize) {
    // Start in the center
    rRow = gridSize ~/ 2; // int division in Dart (without remainder)
    rCol = gridSize ~/ 2;
  }

  // Move functions (with boundary checks)
  void moveUp() => setState(() { if (rRow > 0) rRow--; });
  void moveDown() => setState(() { if (rRow < gridSize - 1) rRow++; });
  void moveLeft() => setState(() { if (rCol > 0) rCol--; });
  void moveRight() => setState(() { if (rCol < gridSize - 1) rCol++; });

  @override
  Widget build(BuildContext context) {
    // Build the grid from Cells
    Column squares = Column(children: <Row>[]);

    // Outer loop builds each row
    for (int row = 0; row < gridSize; row++) {
      Row r = Row(children: []);
      // Inner loop fills each row with cell widgets
      for (int col = 0; col < gridSize; col++) {
        // rhs to show "R" in the selected cell
        r.children.add(Cell(row, col, rhs: this));
      }
      squares.children.add(r);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("HW 2: Robot (Dmitrii Novikov)")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          squares,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ControlButton("up", onPressed: moveUp)),
              Expanded(child: ControlButton("down", onPressed: moveDown)),
              Expanded(child: ControlButton("left", onPressed: moveLeft)),
              Expanded(child: ControlButton("right", onPressed: moveRight)),
            ],
          ),
        ],
      ),
    );
  }
}

// Draw one square; show "R" if this is the robot’s location
class Cell extends StatelessWidget {
  final int row;
  final int col;
  final RobotHomeState rhs;

  Cell(this.row, this.col, {required this.rhs, super.key});

  @override
  Widget build(BuildContext context) {
    bool isRobot = (row == rhs.rRow && col == rhs.rCol);

    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(isRobot ? "R" : "", style: const TextStyle(fontSize: 36)),
    );
  }
}

// Reusable button widget
class ControlButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  ControlButton(this.label, {required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}