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
  String? selectedChore;
  bool isCustomChore = false;

  List<String> chores = [
    'Laundry',
    'Dishwasher',
    'Iron Clothes',
    'Vacuum',
    'Charge EV',
    'Other...',
  ];

  List<Map<String, dynamic>> timeSlots = [];
  ApiService apiService = ApiService();

  String formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd h a').format(dt);
  }

  String formatFromApi(String dtString) {
    final dt = DateTime.parse(dtString);
    return DateFormat('MMM d, y h a').format(dt);
  }

  Future<void> getTimeSlots() async {
    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select both start and end date-times."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (!isCustomChore &&
        (selectedChore == null || selectedChore!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a task."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final maxAllowed = now.add(Duration(hours: 72));
    if (startDateTime!.isAfter(endDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Start time must be before end time."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (endDateTime!.isAfter(maxAllowed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("End time must be within 72 hours from now."),
          duration: Duration(seconds: 1),
        ),
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

      responseData.sort(
        (a, b) => a['avg_direct_ci'].compareTo(b['avg_direct_ci']),
      );
      setState(() {
        timeSlots = responseData;
      });
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  Color getCardColor(int index) {
    if (index == 0) return Colors.green.shade400;
    if (index == 1) return Colors.lightGreen.shade300;
    if (index == 2) return Colors.yellow.shade300;
    return Colors.white;
  }

  Color getTextColor(int index) {
    return index < 3 ? Colors.black : Colors.black87;
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
                hint: Text("Select a task"),
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
                      isCustomChore = value == 'Other...';
                    });
                  }
                },
              ),

              if (isCustomChore) ...[
                SizedBox(height: 12),
                TextField(
                  controller: customChoreController,
                  decoration: InputDecoration(
                    labelText: 'Other',
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
                  Text("Start Time:"),
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
                  Text("End Time:"),
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

              SizedBox(height: 24),
              Text(
                "Enter Duration",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
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

              if (timeSlots.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  "Top Energy Saving Hours",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
              ],

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  final color = getCardColor(index);
                  final textColor = getTextColor(index);

                  return Card(
                    color: color,
                    child: ListTile(
                      onTap: () async {
                        final choreName =
                            isCustomChore
                                ? customChoreController.text
                                : selectedChore;

                        bool? addToDo = await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Add to To-Do List?'),
                                content: Text(
                                  'Do you want to schedule $choreName at this time?',
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
                            'chore': choreName!,
                            'start': slot['start'],
                            'end': slot['end'],
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$choreName scheduled from ${formatFromApi(slot['start'])} to ${formatFromApi(slot['end'])}',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🕓 Start: ${formatFromApi(slot['start'])}",
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "⏰ End:   ${formatFromApi(slot['end'])}",
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "🔥 Carbon Intensity: ${slot['avg_direct_ci']} gCO₂eq/kWh",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
