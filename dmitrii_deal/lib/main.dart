// Dmitrii Novikov
// TAC 368 HW6: Deal or No Deal

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (context) => GameCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const DealGame(),
      ),
    );
  }
}

class GameState
{
  List<int> moneyList;
  List<int> caseList;
  List<bool> openedList;

  int holdCase;
  bool choosingHold;
  bool choosingCase;
  bool waitingDeal;
  bool gameOver;

  int offer;
  int winnings;
  String msg;

  GameState({
    required this.moneyList,
    required this.caseList,
    required this.openedList,
    required this.holdCase,
    required this.choosingHold,
    required this.choosingCase,
    required this.waitingDeal,
    required this.gameOver,
    required this.offer,
    required this.winnings,
    required this.msg,
  });
}

class GameCubit extends Cubit<GameState>
{
  GameCubit() : super(newGame());

  // start a new game and shuffle the money values
  static GameState newGame()
  {
    List<int> money = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];
    List<int> shuffled = List.from(money);
    shuffled.shuffle(Random());

    return GameState(
      moneyList: money,
      caseList: shuffled,
      openedList: List.filled(10, false),
      holdCase: -1,
      choosingHold: true,
      choosingCase: false,
      waitingDeal: false,
      gameOver: false,
      offer: 0,
      winnings: 0,
      msg: "Pick your hold suitcase.",
    );
  }

  void restart()
  {
    emit(newGame());
  }

  // calculate dealer offer from unopened cases
  int getOffer(List<bool> opened, List<int> values)
  {
    int total = 0;
    int count = 0;

    for (int i = 0; i < 10; i++)
    {
      if (opened[i] == false)
      {
        total = total + values[i];
        count = count + 1;
      }
    }

    double avg = total / count;
    return (avg * 0.9).round();
  }

  String moneyString(int x)
  {
    String s = x.toString();
    String answer = "";

    while (s.length > 3)
    {
      answer = "," + s.substring(s.length - 3) + answer;
      s = s.substring(0, s.length - 3);
    }

    answer = s + answer;
    return answer;
  }

  // handle suitcase clicks
  void clickCase(int index)
  {
    if (state.gameOver == true)
    {
      return;
    }

    if (state.choosingHold == true)
    {
      emit(
        GameState(
          moneyList: state.moneyList,
          caseList: state.caseList,
          openedList: state.openedList,
          holdCase: index,
          choosingHold: false,
          choosingCase: true,
          waitingDeal: false,
          gameOver: false,
          offer: 0,
          winnings: 0,
          msg: "You picked case ${index + 1}. Now open one case.",
        ),
      );
      return;
    }

    if (state.choosingCase == false)
    {
      return;
    }

    if (index == state.holdCase)
    {
      return;
    }

    if (state.openedList[index] == true)
    {
      return;
    }

    List<bool> newOpened = List.from(state.openedList);
    newOpened[index] = true;

    int left = 0;
    for (int i = 0; i < 10; i++)
    {
      if (newOpened[i] == false)
      {
        left = left + 1;
      }
    }

    if (left == 1)
    {
      int finalWin = state.caseList[state.holdCase];

      emit(
        GameState(
          moneyList: state.moneyList,
          caseList: state.caseList,
          openedList: newOpened,
          holdCase: state.holdCase,
          choosingHold: false,
          choosingCase: false,
          waitingDeal: false,
          gameOver: true,
          offer: 0,
          winnings: finalWin,
          msg: "Only your case is left. You won \$${moneyString(finalWin)}.",
        ),
      );
      return;
    }

    int newOffer = getOffer(newOpened, state.caseList);

    emit(
      GameState(
        moneyList: state.moneyList,
        caseList: state.caseList,
        openedList: newOpened,
        holdCase: state.holdCase,
        choosingHold: false,
        choosingCase: false,
        waitingDeal: true,
        gameOver: false,
        offer: newOffer,
        winnings: 0,
        msg: "Case ${index + 1} had \$${moneyString(state.caseList[index])}. Dealer offers \$${moneyString(newOffer)}.",
      ),
    );
  }

  // if player accepts the current offer
  void deal()
  {
    if (state.waitingDeal == false)
    {
      return;
    }

    if (state.gameOver == true)
    {
      return;
    }

    emit(
      GameState(
        moneyList: state.moneyList,
        caseList: state.caseList,
        openedList: state.openedList,
        holdCase: state.holdCase,
        choosingHold: false,
        choosingCase: false,
        waitingDeal: false,
        gameOver: true,
        offer: state.offer,
        winnings: state.offer,
        msg: "DEAL! You won \$${moneyString(state.offer)}. Your case had \$${moneyString(state.caseList[state.holdCase])}.",
      ),
    );
  }

  void noDeal()
  {
    if (state.waitingDeal == false)
    {
      return;
    }

    if (state.gameOver == true)
    {
      return;
    }

    emit(
      GameState(
        moneyList: state.moneyList,
        caseList: state.caseList,
        openedList: state.openedList,
        holdCase: state.holdCase,
        choosingHold: false,
        choosingCase: true,
        waitingDeal: false,
        gameOver: false,
        offer: state.offer,
        winnings: 0,
        msg: "NO DEAL. Open another case.",
      ),
    );
  }
}

class DealGame extends StatelessWidget
{
  const DealGame({super.key});

  void keyPress(BuildContext context, String key)
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);

    if (key == 'd' || key == 'D')
    {
      gc.deal();
    }
    else if (key == 'n' || key == 'N')
    {
      gc.noDeal();
    }
    else if (key == '1')
    {
      gc.clickCase(0);
    }
    else if (key == '2')
    {
      gc.clickCase(1);
    }
    else if (key == '3')
    {
      gc.clickCase(2);
    }
    else if (key == '4')
    {
      gc.clickCase(3);
    }
    else if (key == '5')
    {
      gc.clickCase(4);
    }
    else if (key == '6')
    {
      gc.clickCase(5);
    }
    else if (key == '7')
    {
      gc.clickCase(6);
    }
    else if (key == '8')
    {
      gc.clickCase(7);
    }
    else if (key == '9')
    {
      gc.clickCase(8);
    }
    else if (key == '0')
    {
      gc.clickCase(9);
    }
  }

  Widget makeCaseButton(BuildContext context, int index)
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState st = gc.state;

    String label = "Case ${index + 1}";

    if (index == st.holdCase)
    {
      label = "Case ${index + 1}\nHOLD";
    }

    if (st.openedList[index] == true)
    {
      label = "Case ${index + 1}\n\$${gc.moneyString(st.caseList[index])}";
    }

    bool ok = false;

    if (st.choosingHold == true)
    {
      ok = true;
    }
    else if (st.choosingCase == true)
    {
      if (st.openedList[index] == false && index != st.holdCase)
      {
        ok = true;
      }
    }

    return ElevatedButton(
      onPressed: ok
          ? ()
            {
              gc.clickCase(index);
            }
          : null,
      child: SizedBox(
        width: 85,
        height: 55,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget makeMoneyList(BuildContext context)
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState st = gc.state;

    List<Widget> words = [];

    for (int i = 0; i < st.moneyList.length; i++)
    {
      int amount = st.moneyList[i];
      bool out = false;

      for (int j = 0; j < 10; j++)
      {
        if (st.openedList[j] == true && st.caseList[j] == amount)
        {
          out = true;
        }
      }

      words.add(
        Text(
          "\$${gc.moneyString(amount)}",
          style: TextStyle(
            fontSize: 18,
            color: out ? Colors.grey : Colors.black,
            decoration: out ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: words,
    );
  }

  @override
  Widget build(BuildContext context)
  {
    final FocusNode node = FocusNode();

    return KeyboardListener(
      focusNode: node,
      autofocus: true,
      onKeyEvent: (event)
      {
        if (event is KeyDownEvent)
        {
          keyPress(context, event.logicalKey.keyLabel);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Deal or No Deal"),
          actions: [
            TextButton(
              onPressed: ()
              {
                BlocProvider.of<GameCubit>(context).restart();
              },
              child: const Text(
                "Restart",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<GameCubit, GameState>(
          builder: (context, state)
          {
            GameCubit gc = BlocProvider.of<GameCubit>(context);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                    ),
                    child: Text(
                      state.msg,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (state.waitingDeal == true)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        border: Border.all(width: 2),
                      ),
                      child: Text(
                        "Dealer Offer: \$${gc.moneyString(state.offer)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              makeCaseButton(context, 0),
                              makeCaseButton(context, 1),
                              makeCaseButton(context, 2),
                              makeCaseButton(context, 3),
                              makeCaseButton(context, 4),
                              makeCaseButton(context, 5),
                              makeCaseButton(context, 6),
                              makeCaseButton(context, 7),
                              makeCaseButton(context, 8),
                              makeCaseButton(context, 9),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: makeMoneyList(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: state.waitingDeal == true
                            ? ()
                              {
                                gc.deal();
                              }
                            : null,
                        child: const Text("DEAL"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: state.waitingDeal == true
                            ? ()
                              {
                                gc.noDeal();
                              }
                            : null,
                        child: const Text("NO DEAL"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Keyboard: d = deal, n = no deal, 1-9 = cases 1-9, 0 = case 10",
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}