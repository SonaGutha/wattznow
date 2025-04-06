import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({
    this.baseUrl =
        'http://10.0.2.2:8000/get_least_direct_ci/',
  }); // URL is defined here

  Future<List<Map<String, dynamic>>> getTimeSlots(
    String startTime,
    String endTime,
    int duration,
  ) async {
    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('Duration: $duration');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "start_time": startTime,
        "end_time": endTime,
        "duration": duration,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load time slots');
    }
  }
}
