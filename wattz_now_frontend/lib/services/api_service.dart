import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://10.0.2.2:8000/least-direct-ci'});

  Future<List<Map<String, dynamic>>> getTimeSlots(
    String startTime,
    String endTime,
    int duration,
  ) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'start_time': startTime,
        'end_time': endTime,
        'duration': duration.toString(),
      },
    );

    print('Final URL: $uri');

    final response = await http.get(uri);

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load time slots');
    }
  }


}
