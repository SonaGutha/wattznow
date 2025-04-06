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
    return DateFormat('yyyy-MM-dd h:mm a').format(dt);
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

  Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(hours: 72)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> pickTime(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24),
              Text(
                "Select Time Slot",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text("Start Time:"),
                  TextButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      DateTime? pickedDate = await pickDate(context, now);
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await pickTime(context);
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
                          style: TextStyle(
                        color:
                            Colors.blue.shade700, // This changes "Select" color
                        fontWeight: FontWeight.bold,
                      ),
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
                      DateTime? pickedDate = await pickDate(
                        context,
                        startDateTime ?? now,
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await pickTime(context);
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
                          style: TextStyle(
                        color:
                            Colors.blue.shade700, // This changes "Select" color
                        fontWeight: FontWeight.bold,
                      ),
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
                  labelStyle: TextStyle(
                    color: Colors.black, 
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, 
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 184, 233, 184),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: getTimeSlots,
                  child: Text(
                    'Get Time Slots',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: color,
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                          Text(
                            "⏰ End:   ${formatFromApi(slot['end'])}",
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "🔥 CI: ${slot['avg_direct_ci']} gCO₂eq/kWh",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
