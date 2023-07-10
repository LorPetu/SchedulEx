<<<<<<< HEAD:code/front-end/schedulex_webapp/lib/DatabaseMethods.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

const SERVER_URL = "127.0.0.1:5000";

void saveStartDate(String sessionID, String startDate, String endDate) async {
  String url =
      'http://' + SERVER_URL + '/setStartEndDate/$sessionID/$startDate/$endDate';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Dates saved successfully.');
    } else {
      print('Failed to save dates. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving start date: $e');
  }
}

void saveSettings(String sessionID, String distCalls, String distExams) async {
  String url =
      'http://' + SERVER_URL + '/setSettings/$sessionID/$distCalls/$distExams';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Settings saved successfully.');
    } else {
      print('Failed to save settings. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving settings: $e');
  }
}


void saveUnavailability(String sessionID, String name, List<String> dates) async {
  String url = 'http://' + SERVER_URL + '/setUnavailability/$sessionID/$name/${dates.join('/')}';

  try {
    final List<Map<String, String>> requestBody = dates
        .map((date) => {'date': date})
        .toList();

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Unavailability saved successfully.');
    } else {
      print('Failed to save unavailability. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving unavailability: $e');
  }
}


void startOptimization(String sessionID) async {
  String url = 'http://' + SERVER_URL + '/startOptimization/$sessionID';

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

Future<List<String>> getSessionList() async {
  String url = 'http://' + SERVER_URL + '/getSessionList';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('getSessionList_OK.');
      print(response.body); // Stampa il corpo della risposta per verificare i dati ricevuti
      final dynamic responseData = json.decode(response.body);
      print(responseData);
      final List<String> sessionIDs = List<String>.from(responseData.map((item) => item.toString()));
      return sessionIDs;
    } else {
      print('Failed getSessionList. Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Exception occurred for getSessionList: $e');
    return [];
  }
}


Future<Map<String, dynamic>> getSessionData(String sessionId) async {
  String url = 'http://' + SERVER_URL + '/getSessionData/$sessionId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('getSessionData_OK.');
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      print('Failed getSessionData. Error: ${response.statusCode}');
      throw Exception('Failed getSessionData. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getSessionData: $e');
    throw Exception('Exception occurred for getSessionData: $e');
  }
}


=======
import 'package:http/http.dart' as http;

const SERVER_URL = "127.0.0.1:5000";

void saveStartDate({
  required String userId,
  required String startDate,
  required String endDate,
}) async {
  String url = 'http://$SERVER_URL/setStartEndDate';

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );

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
  String url = 'http://$SERVER_URL/startOptimization/$userId';

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
>>>>>>> master:code/front-end/schedulex_webapp/lib/BackEndMethods.dart
