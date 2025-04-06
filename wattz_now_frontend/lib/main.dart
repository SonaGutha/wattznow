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

  void addToDo(Map<String, String> task) {
    setState(() => todoList.add(task));
  }

  void removeFromToDo(int index) {
    setState(() => todoList.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattzNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor:Colors.green.shade800, 
          foregroundColor: Colors.white, 
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/scarlethacks.png', height: 28),
                SizedBox(width: 10),
                Text(
                  'WattzNow',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                //Text('🔌', style: TextStyle(fontSize: 20)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Container(
                color: Colors.green.shade600,
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(
                        "Add Task",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Tab(
                      child: Text("To-Do List", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
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
