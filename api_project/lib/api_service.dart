import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class ApiService {
  static const String apiUrl = 'https://bgnuerp.online/api/gradeapi';

  /// Fetches data from the API and returns a list of Student objects
  static Future<List<Student>> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Check if the data is empty before mapping to the Student model
        if (data.isNotEmpty) {
          return data.map((jsonItem) => Student.fromJson(jsonItem)).toList();
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to load data from API, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');
      return []; // Return empty list in case of an error
    }
  }
}
