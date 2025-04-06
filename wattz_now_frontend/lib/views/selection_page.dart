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
  TextEditingController customChoreController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;

  String selectedChore = 'Washing Clothes';
  bool isCustomChore = false;

  List<String> chores = [
    'Washing Clothes',
    'Dishwasher',
    'Ironing',
    'Vacuuming',
    'Charging EV',
    'Custom...',
  ];

  List<Map<String, dynamic>> timeSlots = [];
  Map<String, dynamic>? bestTimeSlot;

  ApiService apiService = ApiService();

  String formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd h:mm a').format(dt);
  }

  Future<void> getTimeSlots() async {
    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both start and end date-times.")),
      );
      return;
    }

    final now = DateTime.now();
    final maxAllowed = now.add(Duration(hours: 72));

    if (startDateTime!.isAfter(endDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Start time must be before end time.")),
      );
      return;
    }

    if (endDateTime!.isAfter(maxAllowed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("End time must be within 72 hours from now.")),
      );
      return;
    }

    String start = formatDateTime(startDateTime!);
    String end = formatDateTime(endDateTime!);
    int duration = int.tryParse(windowController.text) ?? 1;

    try {
      List<Map<String, dynamic>> responseData = await apiService.getTimeSlots(
        start,
        end,
        duration,
      );

      setState(() {
        timeSlots = responseData;
        bestTimeSlot = timeSlots.reduce(
          (a, b) => a['avg_direct_ci'] < b['avg_direct_ci'] ? a : b,
        );
      });
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Task",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedChore,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items:
                    chores
                        .map(
                          (chore) => DropdownMenuItem(
                            value: chore,
                            child: Text(chore),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedChore = value;
                      isCustomChore = value == 'Custom...';
                    });
                  }
                },
              ),

              if (isCustomChore) ...[
                SizedBox(height: 12),
                TextField(
                  controller: customChoreController,
                  decoration: InputDecoration(
                    labelText: 'Enter your custom task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              SizedBox(height: 24),
              Text(
                "Select Time Slot",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Text("Start:"),
                  TextButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: now.add(Duration(hours: 72)),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text(
                      startDateTime != null
                          ? formatDateTime(startDateTime!)
                          : 'Select',
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text("End:"),
                  TextButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDateTime ?? now,
                        firstDate: startDateTime ?? now,
                        lastDate: now.add(Duration(hours: 72)),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Text(
                      endDateTime != null
                          ? formatDateTime(endDateTime!)
                          : 'Select',
                    ),
                  ),
                ],
              ),

              TextField(
                controller: windowController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (hours)',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 12),
              ElevatedButton(
                onPressed: getTimeSlots,
                child: Text('Get Time Slots'),
              ),

              SizedBox(height: 20),
              if (bestTimeSlot != null) ...[
                Text(
                  "Best time slot for ${isCustomChore ? customChoreController.text : selectedChore}:",
                ),
                Text("Start: ${bestTimeSlot!['start']}"),
                Text("End: ${bestTimeSlot!['end']}"),
                Text("Carbon Intensity: ${bestTimeSlot!['avg_direct_ci']}"),
              ],

              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                                  'Do you want to schedule ${isCustomChore ? customChoreController.text : selectedChore} at this time?',
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
                                '${isCustomChore ? customChoreController.text : selectedChore} scheduled from ${slot['start']} to ${slot['end']}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
