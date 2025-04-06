import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class SelectionPage extends StatefulWidget {
  final Function(Map<String, String>) addToDo;
  SelectionPage({required this.addToDo});
  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  TextEditingController windowController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 0, minute: 0);
  String selectedChore = 'Washing Clothes';

  List<String> chores = [
    'Washing Clothes',
    'Dishwasher',
    'Ironing',
    'Vacuuming',
    'Charging EV',
    'Custom...'
  ];

  TextEditingController customChoreController = TextEditingController();
  bool isCustomChore = false;

  List<Map<String, dynamic>> timeSlots = [];
  Map<String, dynamic>? bestTimeSlot;

  ApiService apiService = ApiService(); 

  Future<void> getTimeSlots() async {
    String startDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String startDateTime = '$startDate ${startTime.format(context)}';
    String endDateTime = '$startDate ${endTime.format(context)}';

    int duration = int.tryParse(windowController.text) ?? 1;

    try {
      List<Map<String, dynamic>> responseData = await apiService.getTimeSlots(
        startDateTime,
        endDateTime,
        duration,
      );

      setState(() {
        timeSlots = responseData;
        bestTimeSlot = timeSlots.reduce(
          (a, b) => a['avg_direct_ci'] < b['avg_direct_ci'] ? a : b,
        );
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Time Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedChore,
              decoration: InputDecoration(labelText: 'Select Task'),
              items:
                  chores.map((chore) {
                    return DropdownMenuItem(value: chore, child: Text(chore));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedChore = value;
                    isCustomChore = value == 'Custom...';
                  });
                }
              },
            ),

            if (isCustomChore)
              TextField(
                controller: customChoreController,
                decoration: InputDecoration(
                  labelText: 'Enter your custom task',
                ),
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text("Select Date:"),
                TextButton(
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 3)),
                    );
                    if (selected != null) {
                      setState(() {
                        selectedDate = selected;
                      });
                    }
                  },
                  child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                ),
              ],
            ),

            Row(
              children: [
                Text("Start Time:"),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      setState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
                Text(startTime.format(context)),
              ],
            ),

            Row(
              children: [
                Text("End Time:"),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      setState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
                Text(endTime.format(context)),
              ],
            ),

            TextField(
              controller: windowController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Duration (hours)'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: getTimeSlots,
              child: Text('Get Time Slots'),
            ),

            SizedBox(height: 20),
            if (bestTimeSlot != null) ...[
              Text("Best time slot for $selectedChore:"),
              Text("Start: ${bestTimeSlot!['start']}"),
              Text("End: ${bestTimeSlot!['end']}"),
              Text("Carbon Intensity: ${bestTimeSlot!['avg_direct_ci']}"),
            ],

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  return Card(
                    child: ListTile(
                      title: Text("Start: ${slot['start']}"),
                      subtitle: Text("End: ${slot['end']}"),
                      trailing: Text("CI: ${slot['avg_direct_ci']}"),
                      onTap: () async {
                        bool? addToDo = await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Add to To-Do List?'),
                                content: Text(
                                  'Do you want to schedule $selectedChore at this time?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text('Yes'),
                                  ),
                                ],
                              ),
                        );

                        if (addToDo == true) {
                          widget.addToDo({
                            'chore':
                                isCustomChore
                                    ? customChoreController.text
                                    : selectedChore,
                            'start': slot['start'],
                            'end': slot['end'],
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$selectedChore scheduled from ${slot['start']} to ${slot['end']}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
