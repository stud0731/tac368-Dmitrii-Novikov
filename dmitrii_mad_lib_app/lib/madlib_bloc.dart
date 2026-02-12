// Dmitrii Novikov
// TAC 368 Lab 10: Mad Lib (Version 1)
// BLoC

import "package:flutter_bloc/flutter_bloc.dart";

// events
abstract class MadlibEvent {}

class UpdateField extends MadlibEvent
{
  final String field;
  final String value;
  UpdateField(this.field, this.value);
}

class GenerateStory extends MadlibEvent {}
class ClearStory extends MadlibEvent {}

// state
class MadlibState
{
  final String animal;
  final String place;
  final String number;
  final String thing;
  final String story;
  final String lastMsg;

  MadlibState(this.animal, this.place, this.number, this.thing, this.story, this.lastMsg);
}

class MadlibBloc extends Bloc<MadlibEvent, MadlibState>
{
  MadlibBloc() : super(MadlibState("", "", "", "", "", ""))
  {
    on<UpdateField>(updateField);
    on<GenerateStory>(generateStory);
    on<ClearStory>(clearStory);
  }

  void updateField(UpdateField event, Emitter<MadlibState> emit)
  {
    String a = state.animal;
    String p = state.place;
    String n = state.number;
    String t = state.thing;

    if (event.field == "animal") a = event.value;
    if (event.field == "place")  p = event.value;
    if (event.field == "number") n = event.value;
    if (event.field == "thing")  t = event.value;

    emit(MadlibState(a, p, n, t, state.story, ""));
  }

  void clearStory(ClearStory event, Emitter<MadlibState> emit)
  {
    emit(MadlibState(state.animal, state.place, state.number, state.thing, "", ""));
  }

  void generateStory(GenerateStory event, Emitter<MadlibState> emit)
  {
    String animal = state.animal.trim();
    String place  = state.place.trim();
    String number = state.number.trim();
    String thing  = state.thing.trim();

    if (animal.length == 0 || place.length == 0 || number.length == 0 || thing.length == 0)
    {
      emit(MadlibState(state.animal, state.place, state.number, state.thing, "", "fill in all blanks first"));
      return;
    }

    String story =
      "When I was in " + place + ", I bought a pet " + animal + ".\n"
      "I traded " + number + " " + thing + " to get the " + animal + ".";

    emit(MadlibState(state.animal, state.place, state.number, state.thing, story, "generated story"));
  }
}