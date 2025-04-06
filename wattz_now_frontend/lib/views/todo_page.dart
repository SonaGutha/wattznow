import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoPage extends StatelessWidget {
  final List<Map<String, String>> todoList;
  final Function(int) removeFromToDo;

  ToDoPage({required this.todoList, required this.removeFromToDo});

  @override
  Widget build(BuildContext context) {
    // Group tasks by date
    Map<String, List<Map<String, String>>> groupedTasks = {};

    for (var i = 0; i < todoList.length; i++) {
      final task = todoList[i];
       DateTime start = DateTime.parse(task['start']!);
      String dateKey = DateFormat('yyyy-MM-dd').format(start);

      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }

      groupedTasks[dateKey]!.add({...task, 'index': i.toString()});
    }

    final sortedDates = groupedTasks.keys.toList()..sort();

    return Scaffold(
      body: ListView.builder(
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          String dateKey = sortedDates[index];
          DateTime parsedDate = DateTime.parse(dateKey);
          String displayDate = DateFormat(
            'EEEE, MMM d, yyyy',
          ).format(parsedDate);
          List<Map<String, String>> tasks = groupedTasks[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  displayDate,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...tasks.map((task) {
                DateTime start = DateTime.parse(task['start']!);
                DateTime end = DateTime.parse(task['end']!);

                String timeRange =
                    '${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}';

                return Card(
                  child: ListTile(
                    title: Text('${task['chore']}'),
                    subtitle: Text(timeRange),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        final index = int.parse(task['index']!);
                        final choreName = task['chore']!;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$choreName removed from your schedule',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        removeFromToDo(index);
                      },

                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
