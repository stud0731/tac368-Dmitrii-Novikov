// Dmitrii Novikov
// TAC 368 HW4: Converter

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'converter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(create: (_) => CalcBloc(), child: const CalcPage()),
    );
  }
}

class CalcPage extends StatelessWidget {
  const CalcPage({super.key});

  // display box
  Widget display(String text) => Container(
        width: 230,
        height: 70,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(border: Border.all(width: 3)),
        child: Text(text, style: const TextStyle(fontSize: 30)),
      );

  // number buttons
  Widget numBtn(BuildContext c, String t) => SizedBox(
        width: 70,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.deepPurple,
            elevation: 2,
          ),
          onPressed: () => c.read<CalcBloc>().add(Digit(t)),
          child: Text(t, style: const TextStyle(fontSize: 22)),
        ),
      );

  // symbol buttons (. and -) and clear button
  Widget symBtn(BuildContext c, String t, CalcEvent e) => SizedBox(
        width: 70,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.deepPurple,
          ),
          onPressed: () => c.read<CalcBloc>().add(e),
          child: Text(t, style: const TextStyle(fontSize: 22)),
        ),
      );

  // operation buttons (right column)
  Widget actBtn(BuildContext c, String t, CalcEvent e) => SizedBox(
        width: 130,
        height: 65,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () => c.read<CalcBloc>().add(e),
          child: Text(t, style: const TextStyle(fontSize: 20)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Converter')),
      body: Center(
        child: BlocBuilder<CalcBloc, CalcState>(builder: (context, s) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              display(s.input),
              const SizedBox(width: 6),
              display(s.output),
            ]),

            const SizedBox(height: 12),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // keypad
              Column(children: [

                // keypad grid
                Row(children: [numBtn(context,'7'),numBtn(context,'8'),numBtn(context,'9')]),
                Row(children: [numBtn(context,'4'),numBtn(context,'5'),numBtn(context,'6')]),
                Row(children: [numBtn(context,'1'),numBtn(context,'2'),numBtn(context,'3')]),
                Row(children: [
                  symBtn(context,'.',Dot()),
                  numBtn(context,'0'),
                  symBtn(context,'-',Neg()),
                ]),

                const SizedBox(height: 10),

                // clear button below main grid
                SizedBox(
                  width: 210,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.deepPurple,
                    ),
                    onPressed: () => context.read<CalcBloc>().add(Clear()),
                    child: const Text("Clear", style: TextStyle(fontSize: 22)),
                  ),
                ),
              ]),

              const SizedBox(width: 12),

              // operations
              Column(children: [
                actBtn(context,'C-F',CF()),
                actBtn(context,'F-C',FC()),
                actBtn(context,'Kg-Lb',KgLb()),
                actBtn(context,'Lb-Kg',LbKg()),
              ])
            ])
          ]);
        }),
      ),
    );
  }
}