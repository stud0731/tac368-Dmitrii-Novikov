// Dmitrii Novikov
// TAC 368 Lab 17: Weather

// api key bbc3a4e69f5a40b9b35203718251103
// weatherapi.com

// Barrett Koster 2024

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bb.dart';

void main()
{
  runApp(const WeatherApi());
}

// holds the weather message
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

class WeatherApi extends StatelessWidget
{
  const WeatherApi({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: "weather demo",
      home: Scaffold(
        appBar: AppBar(title: const Text("weather demo")),
        body: const Row(
          children: [
            Weather1(),
          ],
        ),
      ),
    );
  }
}

class Weather1 extends StatelessWidget
{
  const Weather1({super.key});

  @override
  Widget build(BuildContext context)
  {
    final TextEditingController zipController =
        TextEditingController(text: "90802");

    return BlocProvider<MsgCubit>(
      create: (context) => MsgCubit(),
      child: BlocBuilder<MsgCubit, MsgState>(
        builder: (context, state)
        {
          return Builder(
            builder: (context)
            {
              MsgCubit mc = BlocProvider.of<MsgCubit>(context);

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BB("Enter ZIP code:"),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: zipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "ex: 90007",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        BB("Weather: "),
                        BB(mc.state.msg),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async
                      {
                        String zip = zipController.text.trim();
                        String weatherMsg = await _networkCall(zip);
                        mc.update(weatherMsg);
                      },
                      child: BB("get weather"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _networkCall(String zip) async
  {
    final url = Uri.parse(
      'http://api.weatherapi.com/v1/current.json'
      '?key=bbc3a4e69f5a40b9b35203718251103&q=$zip&aqi=no'
    );

    final response = await http.get(url);

    if (response.statusCode != 200)
    {
      return "Network error: ${response.statusCode}";
    }

    Map<String, dynamic> dataAsMap = jsonDecode(response.body);
    print("Let's see what the weather thingy sent us ...");
    print(dataAsMap);

    if (dataAsMap['error'] != null)
    {
      return "Bad zip code";
    }

    Map<String, dynamic> dig1 = dataAsMap['current'];

    double tempC = dig1['temp_c'];
    double windMph = dig1['wind_mph'];

    return "Temp: $tempC C, Wind: $windMph mph";
  }
}