// Dmitrii Novikov
// TAC 368 Lab 18: API (Currency Converter)

// Frankfurter currency API
// https://api.frankfurter.dev/v1/latest?base=USD&symbols=EUR

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bb.dart';

void main()
{
  runApp(const CurrencyApi());
}

class MsgState
{
  String msg;
  MsgState(this.msg);
}

class MsgCubit extends Cubit<MsgState>
{
  MsgCubit() : super(MsgState("No data yet"));
  void update(String m) { emit(MsgState(m)); }
}

class CurrencyApi extends StatelessWidget
{
  const CurrencyApi({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Currency Converter",
      home: Scaffold(
        appBar: AppBar(title: const Text("Currency Converter")),
        body: const Currency1(),
      ),
    );
  }
}

class Currency1 extends StatelessWidget
{
  const Currency1({super.key});

  @override
  Widget build(BuildContext context)
  {
    final amountController = TextEditingController(text: "10");
    final fromController = TextEditingController(text: "USD");
    final toController = TextEditingController(text: "EUR");

    return BlocProvider(
      create: (context) => MsgCubit(),
      child: BlocBuilder<MsgCubit, MsgState>(
        builder: (context, state)
        {
          MsgCubit mc = BlocProvider.of<MsgCubit>(context);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Enter amount:", style: TextStyle(fontSize: 18)),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 15),

                  const Text("From currency:", style: TextStyle(fontSize: 18)),
                  TextField(controller: fromController),

                  const SizedBox(height: 15),

                  const Text("To currency:", style: TextStyle(fontSize: 18)),
                  TextField(controller: toController),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async
                    {
                      String amount = amountController.text.trim();
                      String from = fromController.text.trim().toUpperCase();
                      String to = toController.text.trim().toUpperCase();

                      String result = await _networkCall(amount, from, to);
                      mc.update(result);
                    },
                    child: const Text("Convert"),
                  ),

                  const SizedBox(height: 20),

                  const Text("Result:", style: TextStyle(fontSize: 18)),
                  Text(
                    mc.state.msg,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Supported currencies:\n\n"
                      "USD, EUR, GBP, JPY, AUD, CAD, CHF, BRL and more.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> _networkCall(String amountStr, String from, String to) async
  {
    double? amount = double.tryParse(amountStr);

    if (amount == null) return "Bad amount";
    if (from.isEmpty || to.isEmpty) return "Enter currency codes";

    final url = Uri.parse(
      'https://api.frankfurter.dev/v1/latest?base=$from&symbols=$to'
    );

    final response = await http.get(url);

    if (response.statusCode != 200)
    {
      return "Network error";
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    if (data['rates'] == null || data['rates'][to] == null)
    {
      return "Bad currency";
    }

    double rate = (data['rates'][to] as num).toDouble();
    double converted = amount * rate;

    return "${amount.toStringAsFixed(2)} $from = "
           "${converted.toStringAsFixed(2)} $to";
  }
}