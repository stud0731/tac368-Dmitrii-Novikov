// Dmitrii Novikov
// TAC 368 HW5: Quizzle

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const QuizzleApp());
}

class QuizzleApp extends StatelessWidget {
  const QuizzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => QuizBloc(),
        child: const QuizPage(),
      ),
    );
  }
}

class QAItem {
  final String question;
  final String answer;
  QAItem(this.question, this.answer);
}

enum QuizStatus { idle, loading, ready, finished, error }
enum QuizMode { multipleChoice, freeResponse }

class QuizState {
  final QuizStatus status;

  final String? selectedLabel;
  final String questionLabel;
  final String answerLabel;

  final List<QAItem> items;
  final int index;

  final int attempted;
  final int correct;

  // question mode
  final QuizMode mode;

  // multiple choice
  final List<String> options;
  final String? selectedOption;

  // free response
  final String freeResponse;

  // feedback
  final bool checked;
  final String feedback;

  final String errorMessage;

  const QuizState({
    required this.status,
    required this.selectedLabel,
    required this.questionLabel,
    required this.answerLabel,
    required this.items,
    required this.index,
    required this.attempted,
    required this.correct,
    required this.mode,
    required this.options,
    required this.selectedOption,
    required this.freeResponse,
    required this.checked,
    required this.feedback,
    required this.errorMessage,
  });

  factory QuizState.initial() {
    return const QuizState(
      status: QuizStatus.idle,
      selectedLabel: null,
      questionLabel: "question",
      answerLabel: "answer",
      items: [],
      index: 0,
      attempted: 0,
      correct: 0,
      mode: QuizMode.freeResponse, // default mode is free response
      options: [],
      selectedOption: null,
      freeResponse: "",
      checked: false,
      feedback: "",
      errorMessage: "",
    );
  }

  QuizState copyWith({
    QuizStatus? status,
    String? selectedLabel,
    String? questionLabel,
    String? answerLabel,
    List<QAItem>? items,
    int? index,
    int? attempted,
    int? correct,
    QuizMode? mode,
    List<String>? options,
    String? selectedOption,
    String? freeResponse,
    bool? checked,
    String? feedback,
    String? errorMessage,
    bool clearSelectedOption = false,
    bool clearFreeResponse = false,
  }) {
    return QuizState(
      status: status ?? this.status,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      questionLabel: questionLabel ?? this.questionLabel,
      answerLabel: answerLabel ?? this.answerLabel,
      items: items ?? this.items,
      index: index ?? this.index,
      attempted: attempted ?? this.attempted,
      correct: correct ?? this.correct,
      mode: mode ?? this.mode,
      options: options ?? this.options,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      freeResponse: clearFreeResponse ? "" : (freeResponse ?? this.freeResponse),
      checked: checked ?? this.checked,
      feedback: feedback ?? this.feedback,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// events
abstract class QuizEvent {}

class QuizLoadRequested extends QuizEvent {
  final String label;
  QuizLoadRequested(this.label);
}

class QuizOptionSelected extends QuizEvent {
  final String option;
  QuizOptionSelected(this.option);
}

class QuizFreeResponseChanged extends QuizEvent {
  final String text;
  QuizFreeResponseChanged(this.text);
}

class QuizModeChanged extends QuizEvent {
  final QuizMode mode;
  QuizModeChanged(this.mode);
}

class QuizCheckPressed extends QuizEvent {}

class QuizNextPressed extends QuizEvent {}

// Bloc
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizState.initial()) {
    on<QuizLoadRequested>(_onLoad);
    on<QuizOptionSelected>(_onSelectOption);
    on<QuizFreeResponseChanged>(_onFreeResponseChanged);
    on<QuizModeChanged>(_onModeChanged);
    on<QuizCheckPressed>(_onCheck);
    on<QuizNextPressed>(_onNext);
  }

  final Map<String, String> files = const {
    'State Capitals': 'assets/statecapitals.txt',
    'Elements': 'assets/elements.txt',
  };

  final Random _rng = Random();

  Future<void> _onLoad(QuizLoadRequested event, Emitter<QuizState> emit) async {
    emit(state.copyWith(
      status: QuizStatus.loading,
      feedback: "",
      checked: false,
      errorMessage: "",
    ));

    try {
      final path = files[event.label];
      if (path == null) {
        emit(state.copyWith(status: QuizStatus.error, errorMessage: "Unknown dataset."));
        return;
      }

      final text = await rootBundle.loadString(path);

      final lines = text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        emit(state.copyWith(status: QuizStatus.error, errorMessage: "File is empty."));
        return;
      }

      // header line ("state,capital") or ("atomic number,element")
      final header = _splitOnce(lines[0]);
      final qLabel = header.$1.trim();
      final aLabel = header.$2.trim();

      final List<QAItem> parsed = [];
      for (int i = 1; i < lines.length; i++) {
        final parts = _splitOnce(lines[i]);
        final q = parts.$1.trim();
        final a = parts.$2.trim();
        if (q.isNotEmpty && a.isNotEmpty) {
          parsed.add(QAItem(q, a));
        }
      }

      if (parsed.length < 4) {
        emit(state.copyWith(
          status: QuizStatus.error,
          errorMessage: "Need at least 4 rows for multiple choice.",
        ));
        return;
      }

      parsed.shuffle(_rng);

      emit(state.copyWith(
        status: QuizStatus.ready,
        selectedLabel: event.label,
        questionLabel: qLabel.isEmpty ? "question" : qLabel,
        answerLabel: aLabel.isEmpty ? "answer" : aLabel,
        items: parsed,
        index: 0,
        attempted: 0,
        correct: 0,
        mode: QuizMode.freeResponse, // default mode is free response
        options: _buildOptions(parsed, 0),
        clearSelectedOption: true,
        clearFreeResponse: true,
        checked: false,
        feedback: "",
      ));
    } catch (e) {
      emit(state.copyWith(status: QuizStatus.error, errorMessage: "Load failed: $e"));
    }
  }

  void _onModeChanged(QuizModeChanged event, Emitter<QuizState> emit) {
    if (state.status != QuizStatus.ready) return;
    if (state.mode == event.mode) return;

    if (event.mode == QuizMode.multipleChoice) {
      emit(state.copyWith(
        mode: QuizMode.multipleChoice,
        options: _buildOptions(state.items, state.index),
        clearSelectedOption: true,
        clearFreeResponse: true,
        checked: false,
        feedback: "",
      ));
    } else {
      emit(state.copyWith(
        mode: QuizMode.freeResponse,
        clearSelectedOption: true,
        clearFreeResponse: true,
        checked: false,
        feedback: "",
      ));
    }
  }

  void _onSelectOption(QuizOptionSelected event, Emitter<QuizState> emit) {
    if (state.status != QuizStatus.ready) return;
    if (state.checked) return;
    if (state.mode != QuizMode.multipleChoice) return;
    emit(state.copyWith(selectedOption: event.option));
  }

  void _onFreeResponseChanged(QuizFreeResponseChanged event, Emitter<QuizState> emit) {
    if (state.status != QuizStatus.ready) return;
    if (state.checked) return;
    if (state.mode != QuizMode.freeResponse) return;
    emit(state.copyWith(freeResponse: event.text));
  }

  void _onCheck(QuizCheckPressed event, Emitter<QuizState> emit) {
    if (state.status != QuizStatus.ready) return;
    if (state.items.isEmpty) return;
    if (state.checked) return;

    final correctAns = state.items[state.index].answer.trim();
    bool isRight = false;

    if (state.mode == QuizMode.multipleChoice) {
      final selected = state.selectedOption;
      if (selected == null) {
        emit(state.copyWith(feedback: "Pick an answer first.", checked: false));
        return;
      }
      isRight = selected.toLowerCase() == correctAns.toLowerCase();
    } else {
      final typed = state.freeResponse.trim();
      if (typed.isEmpty) {
        emit(state.copyWith(feedback: "Type an answer first.", checked: false));
        return;
      }
      isRight = typed.toLowerCase() == correctAns.toLowerCase();
    }

    emit(state.copyWith(
      attempted: state.attempted + 1,
      correct: isRight ? state.correct + 1 : state.correct,
      checked: true,
      feedback: isRight ? "✅ Correct" : "❌ Wrong. Correct answer: $correctAns",
      // clear free response after submitting
      freeResponse: state.mode == QuizMode.freeResponse ? "" : state.freeResponse,
    ));
  }

  void _onNext(QuizNextPressed event, Emitter<QuizState> emit) {
    if (state.status != QuizStatus.ready) return;
    if (!state.checked) return;
    if (state.items.isEmpty) return;

    final nextIndex = (state.index + 1) % state.items.length;

    emit(state.copyWith(
      index: nextIndex,
      options: _buildOptions(state.items, nextIndex),
      clearSelectedOption: true,
      clearFreeResponse: true,
      checked: false,
      feedback: "",
    ));
  }

  // splits at the first comma (inputs like "Alabama,Montgomery" or "1,Hydrogen")
  (String, String) _splitOnce(String line) {
    final comma = line.indexOf(',');
    if (comma == -1) return (line, "");
    return (line.substring(0, comma), line.substring(comma + 1));
  }

  List<String> _buildOptions(List<QAItem> items, int index) {
    final correct = items[index].answer.trim();
    final answers = items.map((e) => e.answer.trim()).toList();

    final Set<String> opts = {correct};
    while (opts.length < 4) {
      final candidate = answers[_rng.nextInt(answers.length)];
      if (candidate.isNotEmpty) opts.add(candidate);
    }

    final list = opts.toList();
    list.shuffle(_rng);
    return list;
  }
}

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuizBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("HW5: Quizzle (Dmitrii Novikov)")),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      "Dataset:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: state.selectedLabel,
                        hint: const Text("Choose a file"),
                        isExpanded: true,
                        items: bloc.files.keys
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<QuizBloc>().add(QuizLoadRequested(value));
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Score: ${state.correct} / ${state.attempted}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Text(
                          "Mode:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),

                        // Free Response first
                        ElevatedButton(
                          onPressed: state.status == QuizStatus.ready
                              ? () => context.read<QuizBloc>().add(
                                    QuizModeChanged(QuizMode.freeResponse),
                                  )
                              : null,
                          child: const Text("Free Response"),
                        ),
                        const SizedBox(width: 8),

                        // Multiple Choice second
                        ElevatedButton(
                          onPressed: state.status == QuizStatus.ready
                              ? () => context.read<QuizBloc>().add(
                                    QuizModeChanged(QuizMode.multipleChoice),
                                  )
                              : null,
                          child: const Text("Multiple Choice"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (state.status == QuizStatus.idle)
                  const Expanded(
                    child: Center(child: Text("Pick a dataset to start.")),
                  )
                else if (state.status == QuizStatus.loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == QuizStatus.error)
                  Expanded(
                    child: Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _QuizCard(state: state),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizState state;
  const _QuizCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final item = state.items[state.index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "What is the ${state.answerLabel} for this ${state.questionLabel}?",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                item.question,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (state.mode == QuizMode.multipleChoice) ...[
                ...state.options.map((opt) {
                  return RadioListTile<String>(
                    value: opt,
                    groupValue: state.selectedOption,
                    onChanged: state.checked
                        ? null
                        : (v) {
                            if (v != null) {
                              context.read<QuizBloc>().add(QuizOptionSelected(v));
                            }
                          },
                    title: Text(opt),
                  );
                }),
              ] else ...[
                TextFormField(
                  // only reset when question/mode/checked changes
                  key: ValueKey("${state.index}-${state.mode}-${state.checked}"),
                  enabled: !state.checked,
                  initialValue: state.freeResponse,
                  decoration: InputDecoration(
                    labelText: state.answerLabel,
                    border: const OutlineInputBorder(),
                    hintText: "Type your answer",
                  ),
                  onChanged: (txt) {
                    context.read<QuizBloc>().add(QuizFreeResponseChanged(txt));
                  },
                  onFieldSubmitted: (_) {
                    if (!state.checked) {
                      context.read<QuizBloc>().add(QuizCheckPressed());
                    }
                  },
                ),              
              ],

              const SizedBox(height: 8),

              Text(
                state.feedback,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: state.feedback.startsWith("✅")
                      ? Colors.green
                      : (state.feedback.startsWith("❌") ? Colors.red : null),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.checked
                          ? null
                          : () => context.read<QuizBloc>().add(QuizCheckPressed()),
                      child: const Text("Check Answer"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.checked
                          ? () => context.read<QuizBloc>().add(QuizNextPressed())
                          : null,
                      child: const Text("Next Question"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}