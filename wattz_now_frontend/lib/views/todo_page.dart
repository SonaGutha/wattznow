import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoPage extends StatefulWidget {
  final List<Map<String, String>> todoList;
  final Function(int) removeFromToDo;

  ToDoPage({required this.todoList, required this.removeFromToDo});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  void _showAddCustomChoreDialog() {
    final choreController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Custom Chore"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: choreController,
                    decoration: InputDecoration(labelText: 'Chore Name'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Date: "),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 7)),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Start: "),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => startTime = picked);
                          }
                        },
                        child: Text(startTime?.format(context) ?? 'Select'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End: "),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => endTime = picked);
                          }
                        },
                        child: Text(endTime?.format(context) ?? 'Select'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (choreController.text.isNotEmpty &&
                    startTime != null &&
                    endTime != null) {
                  final startDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    startTime!.hour,
                    startTime!.minute,
                  );
                  final endDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    endTime!.hour,
                    endTime!.minute,
                  );

                  setState(() {
                    widget.todoList.add({
                      'chore': choreController.text,
                      'start':
                          DateFormat(
                            'EEE, dd MMM yyyy HH:mm:ss',
                          ).format(startDateTime) +
                          ' GMT',
                      'end':
                          DateFormat(
                            'EEE, dd MMM yyyy HH:mm:ss',
                          ).format(endDateTime) +
                          ' GMT',
                    });
                  });

                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ same grouping + rendering logic as before...

    // Step 1: Group tasks by date
    Map<String, List<Map<String, String>>> groupedTasks = {};

    for (var i = 0; i < widget.todoList.length; i++) {
      final task = widget.todoList[i];
      DateTime startDateTime = DateFormat(
        'EEE, dd MMM yyyy HH:mm:ss',
      ).parseUtc(task['start']!.replaceAll('GMT', '').trim());
      String dateKey = DateFormat('yyyy-MM-dd').format(startDateTime);

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
                DateTime start = DateFormat(
                  'EEE, dd MMM yyyy HH:mm:ss',
                ).parseUtc(task['start']!.replaceAll('GMT', '').trim());
                DateTime end = DateFormat(
                  'EEE, dd MMM yyyy HH:mm:ss',
                ).parseUtc(task['end']!.replaceAll('GMT', '').trim());

                String timeRange =
                    '${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}';

                return Card(
                  child: ListTile(
                    title: Text('${task['chore']}'),
                    subtitle: Text(timeRange),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed:
                          () =>
                              widget.removeFromToDo(int.parse(task['index']!)),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomChoreDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Custom Chore',
      ),
    );
  }
}
