// Dmitrii Novikov
// TAC 368 Lab 9: Groceries

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "groceries_bloc.dart";

// provide the groceries bloc one time so the whole widget structure can use it
void main()
{
  runApp(
    BlocProvider(
      create: (_) { return GroceryBloc(); },
      child: GroceriesApp(),
    ),
  );
}

class GroceriesApp extends StatelessWidget
{
  GroceriesApp({super.key});

  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "groceries",
      home: GroceriesPage(),
    );
  }
}

class GroceriesPage extends StatelessWidget
{
  GroceriesPage({super.key});

  final TextEditingController ctrl = TextEditingController();

  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dmitrii Novikov Groceries"),
        actions: [
          IconButton(
            tooltip: "load",
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<GroceryBloc>().add(LoadList());
            },
          ),
          IconButton(
            tooltip: "save",
            icon: Icon(Icons.save),
            onPressed: () {
              context.read<GroceryBloc>().add(SaveList());
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // add row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "add item (chicken, eggs, cucumbers, etc...)",
                    ),
                    onSubmitted: (_) {
                      String s = ctrl.text.trim();
                      if (s.length > 0)
                      {
                        context.read<GroceryBloc>().add(AddItem(s));
                        ctrl.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  tooltip: "add",
                  icon: Icon(Icons.add),
                  onPressed: () {
                    String s = ctrl.text.trim();
                    if (s.length > 0)
                    {
                      context.read<GroceryBloc>().add(AddItem(s));
                      ctrl.clear();
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 12),

            // rebuild this section when list changes
            Expanded(
              child: BlocBuilder<GroceryBloc, GroceryState>(
                builder: (context, state)
                {
                  List<String> items = state.items;

                  if (state.loading)
                  {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (items.length == 0)
                  {
                    return Center(child: Text("no groceries yet"));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i)
                    {
                      return Card(
                        child: ListTile(
                          title: Text(items[i]),
                          trailing: IconButton(
                            tooltip: "delete",
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              context.read<GroceryBloc>().add(DeleteItem(i));
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // small status line
            BlocBuilder<GroceryBloc, GroceryState>(
              builder: (context, state)
              {
                String msg = "";
                if (state.dirty) msg = "unsaved changes";
                if (state.lastMsg.length > 0) msg = state.lastMsg;
                return Text(msg);
              },
            ),
          ],
        ),
      ),
    );
  }
}