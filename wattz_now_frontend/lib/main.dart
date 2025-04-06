import 'package:flutter/material.dart';
import 'views/selection_page.dart';
import 'views/todo_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> todoList = [];

  void addToDo(Map<String, String> chore) {
    setState(() => todoList.add(chore));
  }

  void removeFromToDo(int index) {
    setState(() => todoList.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattzNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("WattzNow"),
            bottom: TabBar(
              tabs: [Tab(text: "Select Chore"), Tab(text: "To-Do List")],
            ),
          ),
          body: TabBarView(
            children: [
              SelectionPage(addToDo: addToDo),
              ToDoPage(todoList: todoList, removeFromToDo: removeFromToDo),
            ],
          ),
        ),
      ),
    );
  }
}
