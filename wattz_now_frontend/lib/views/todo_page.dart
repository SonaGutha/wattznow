import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoPage extends StatelessWidget {
  final List<Map<String, String>> todoList;
  final Function(int) removeFromToDo;

  ToDoPage({required this.todoList, required this.removeFromToDo});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> groupedTasks = {};
    final Map<String, Color> taskColors = {
      'Laundry': Colors.blue.shade100,
      'Dishwasher': Colors.orange.shade200,
      'Iron Clothes': Colors.purple.shade100,
      'Vacuum': Colors.brown.shade100,
      'Charge EV': Colors.teal.shade100,
      'Other': Colors.grey.shade300,
    };

    Color getTaskColor(String choreName) {
      return taskColors[choreName] ?? taskColors['Other']!;
    }

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
              ...(tasks..sort((a, b) {
                    DateTime startA = DateTime.parse(a['start']!);
                    DateTime startB = DateTime.parse(b['start']!);
                    return startA.compareTo(startB);
                  }))
                  .map((task) {
                    DateTime start = DateTime.parse(task['start']!);
                    DateTime end = DateTime.parse(task['end']!);
                    String timeRange =
                        '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';

                    return Dismissible(
                      key: Key(task['start']! + task['chore']!),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
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
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: getTaskColor(task['chore']!),
                        child: ListTile(
                          title: Text('${task['chore']}'),
                          subtitle: Text(timeRange),
                        ),
                      ),
                    );
                  }),
            ],
          );
        },
      ),
    );
  }
}
