import "package:flutter_bloc/flutter_bloc.dart";

class SGState
{
  final int width;
  final int height;

  const SGState(this.width, this.height);

  SGState copyWith({int? width, int? height})
  { return SGState(width ?? this.width, height ?? this.height); }
}

abstract class SGEvent {}
class IncWidth extends SGEvent {}
class DecWidth extends SGEvent {}
class IncHeight extends SGEvent {}
class DecHeight extends SGEvent {}

class SGBloc extends Bloc<SGEvent, SGState>
{
  SGBloc() : super(const SGState(4, 3))
  {
    on<IncWidth>((event, emit) {
      emit(state.copyWith(width: state.width + 1));
    });

    on<DecWidth>((event, emit) {
      int w = state.width - 1;
      if (w < 1) w = 1;
      emit(state.copyWith(width: w));
    });

    on<IncHeight>((event, emit) {
      emit(state.copyWith(height: state.height + 1));
    });

    on<DecHeight>((event, emit) {
      int h = state.height - 1;
      if (h < 1) h = 1;
      emit(state.copyWith(height: h));
    });
  }
}