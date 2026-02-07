// Dmitrii Novikov
// TAC 368 HW3: Lights Out (BLoC)

import "dart:math";
import "package:flutter_bloc/flutter_bloc.dart";

// state = number of lights + list of on/off values
class LOState
{
  final int n;
  final List<bool> lights;

  const LOState(this.n, this.lights);

  // win when all lights are off
  bool solved()
  {
    for (int i = 0; i < lights.length; i++)
    {
      if (lights[i]) return false;
    }
    return true;
  }
}

// events = things the user can do
abstract class LOEvent {}

class ToggleAt extends LOEvent
{
  final int i;
  ToggleAt(this.i);
}

class IncLights extends LOEvent {}
class DecLights extends LOEvent {}
class Randomize extends LOEvent {}

// bloc = handle events and create new states
class LOBloc extends Bloc<LOEvent, LOState>
{
  Random r = Random();

  // start with 9 random lights
  LOBloc() : super(LOState(9, randList(9, Random())))
  {
    // toggle one light + its neighbors
    on<ToggleAt>((event, emit)
    {
      int pos = event.i;

      // copy list so we don’t change old state
      List<bool> arr = List<bool>.from(state.lights);

      flip(arr, pos);
      if (pos > 0) flip(arr, pos - 1);
      if (pos < arr.length - 1) flip(arr, pos + 1);

      emit(LOState(state.n, arr));
    });

    // add one more light (make a new random setup)
    on<IncLights>((event, emit)
    {
      int newN = state.n + 1;
      emit(LOState(newN, randList(newN, r)));
    });

    // remove one light (min 1) and randomize
    on<DecLights>((event, emit)
    {
      int newN = state.n - 1;
      if (newN < 1) newN = 1;
      emit(LOState(newN, randList(newN, r)));
    });

    // just randomize the current size
    on<Randomize>((event, emit)
    {
      emit(LOState(state.n, randList(state.n, r)));
    });
  }

  // flip one index
  static void flip(List<bool> a, int i)
  {
    a[i] = !a[i];
  }

  // make a random list of bools
  static List<bool> randList(int n, Random r)
  {
    List<bool> a = [];
    for (int i = 0; i < n; i++)
    {
      a.add(r.nextBool());
    }
    return a;
  }
}