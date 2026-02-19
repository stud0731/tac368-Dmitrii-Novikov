// Dmitrii Novikov
// TAC 368 HW4: Converter

// converter_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class CalcState {
  final String input;
  final String output;
  final bool fresh; // wait for new input after conversion

  CalcState(this.input, this.output, this.fresh);
}

abstract class CalcEvent {}
class Digit extends CalcEvent { final String d; Digit(this.d); }
class Dot extends CalcEvent {}
class Neg extends CalcEvent {}
class Clear extends CalcEvent {}
class CF extends CalcEvent {}
class FC extends CalcEvent {}
class KgLb extends CalcEvent {}
class LbKg extends CalcEvent {}

class CalcBloc extends Bloc<CalcEvent, CalcState> {
  CalcBloc() : super(CalcState("", "", false)) {

    // type digits
    on<Digit>((e, emit) {
      if (state.fresh) {
        emit(CalcState(e.d, "", false));
      } else {
        emit(CalcState(state.input + e.d, state.output, false));
      }
    });

    // decimal
    on<Dot>((e, emit) {
      if (state.fresh) {
        emit(CalcState("0.", "", false));
        return;
      }
      if (!state.input.contains('.')) {
        emit(CalcState(state.input + '.', state.output, false));
      }
    });

    // negative toggle
    on<Neg>((e, emit) {
      if (state.fresh) {
        emit(CalcState("-", "", false));
        return;
      }

      if (state.input.startsWith('-')) {
        emit(CalcState(state.input.substring(1), state.output, false));
      } else {
        emit(CalcState('-' + state.input, state.output, false));
      }
    });

    // clear
    on<Clear>((e, emit) => emit(CalcState("", "", false)));

    double num() => double.tryParse(state.input) ?? 0.0;

    // conversions => mark fresh = true
    on<CF>((e, emit) =>
        emit(CalcState(state.input, (num()*9/5+32).toStringAsFixed(4), true)));

    on<FC>((e, emit) =>
        emit(CalcState(state.input, ((num()-32)*5/9).toStringAsFixed(4), true)));

    on<KgLb>((e, emit) =>
        emit(CalcState(state.input, (num()*2.20462).toStringAsFixed(4), true)));

    on<LbKg>((e, emit) =>
        emit(CalcState(state.input, (num()/2.20462).toStringAsFixed(4), true)));
  }
}