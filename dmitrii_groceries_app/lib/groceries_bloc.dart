// Dmitrii Novikov
// TAC 368 Lab 9: Groceries BLoC

import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

// events
abstract class GroceryEvent {}

class LoadList extends GroceryEvent {}
class SaveList extends GroceryEvent {}

class AddItem extends GroceryEvent
{
  final String item;
  AddItem(this.item);
}

class DeleteItem extends GroceryEvent
{
  final int index;
  DeleteItem(this.index);
}

// state
class GroceryState
{
  final List<String> items;
  final bool loading;
  final bool dirty;
  final String lastMsg;

  GroceryState(this.items, this.loading, this.dirty, this.lastMsg);
}

class GroceryBloc extends Bloc<GroceryEvent, GroceryState>
{
  static const String keyName = "grocery_list_v1";

  GroceryBloc() : super(GroceryState([], true, false, ""))
  {
    on<LoadList>(loadList);
    on<SaveList>(saveList);
    on<AddItem>(addItem);
    on<DeleteItem>(deleteItem);

    // load when an event is created
    add(LoadList());
  }

  Future<void> loadList(LoadList event, Emitter<GroceryState> emit) async
  {
    emit(GroceryState(state.items, true, state.dirty, ""));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(keyName) ?? [];

    emit(GroceryState(saved, false, false, "loaded"));
  }

  Future<void> saveList(SaveList event, Emitter<GroceryState> emit) async
  {
    emit(GroceryState(state.items, true, state.dirty, ""));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyName, state.items);

    emit(GroceryState(state.items, false, false, "saved"));
  }

  void addItem(AddItem event, Emitter<GroceryState> emit)
  {
    String s = event.item.trim();
    if (s.length == 0) return;

    List<String> next = List<String>.from(state.items);
    next.add(s);

    emit(GroceryState(next, false, true, ""));
  }

  void deleteItem(DeleteItem event, Emitter<GroceryState> emit)
  {
    int i = event.index;
    if (i < 0 || i >= state.items.length) return;

    List<String> next = List<String>.from(state.items);
    next.removeAt(i);

    emit(GroceryState(next, false, true, ""));
  }
}