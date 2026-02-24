// Dmitrii Novikov
// TAC 368 Lab 12: Splash123

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

TextStyle ts = const TextStyle(fontSize: 30);

class CounterState {
  int count;
  CounterState(this.count);
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));
  void inc() {
    emit(CounterState(state.count + 1));
  }
}

void main() {
  runApp(RoutesDemo());
}

class RoutesDemo extends StatelessWidget {
  RoutesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Routes Demo",
      home: TopBloc(),
    );
  }
}

class TopBloc extends StatelessWidget {
  const TopBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (context) => CounterCubit(),
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) => Route1(),
      ),
    );
  }
}

class Route1 extends StatelessWidget {
  final String title = "Route1";
  Route1({super.key});

  @override
  Widget build(BuildContext context) {
    CounterCubit cc = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      appBar: AppBar(title: Text(title, style: ts)),
      body: Column(
        children: [
          Text("page 1", style: ts),
          Text("${cc.state.count}", style: ts),

          ElevatedButton(
            onPressed: () {
              cc.inc();
            },
            child: Text("add 1", style: ts),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Route2(cc: cc),
                ),
              );
            },
            child: Text("go to page 2", style: ts),
          ),

          // Push twice (Route1 to Route2 to Route3)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Route2(cc: cc),
                ),
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Route3(cc: cc),
                ),
              );
            },
            child: Text("go to page 3", style: ts),
          ),
        ],
      ),
    );
  }
}

class Route2 extends StatelessWidget {
  final String title = "Route2";
  final CounterCubit cc;
  Route2({required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("page 2", style: ts),
                Text("${cc.state.count}", style: ts),

                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("add 1", style: ts),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Route3(cc: cc),
                      ),
                    );
                  },
                  child: Text("go to page 3", style: ts),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("go back to page 1", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Route3 extends StatelessWidget {
  final String title = "Route3";
  final CounterCubit cc;
  Route3({required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("page 3", style: ts),
                Text("${cc.state.count}", style: ts),

                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("add 1", style: ts),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Route3 to Route2
                  },
                  child: Text("go back to page 2", style: ts),
                ),

                // Pop twice (Route3 to Route2 to Route1)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("go back to page 1", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}