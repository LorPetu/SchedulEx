import 'package:http/http.dart' as http;

const SERVER_URL = "127.0.0.1:5000";

void saveStartDate(String userId, String startDate, String endDate) async {
  String url =
      'http://' + SERVER_URL + '/setStartEndDate/$userId/$startDate/$endDate';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Dates saved successfully.');
    } else {
      print('Failed to save dates. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving start date: $e');
  }
}

void startOptimization(String userId) async {
  String url = 'http://' + SERVER_URL + '/startOptimization/$userId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Scheduling started successfully.');
    } else {
      print('Failed to start schedule. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while starting scheduling: $e');
  }
}
