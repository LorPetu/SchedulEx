import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:schedulex_webapp/utils.dart';

const SERVER_URL = "127.0.0.1:5000";

void saveUserID({required String sessionID, required String userID}) async {
  String url = 'http://' + SERVER_URL + '/setUserID/$sessionID/$userID';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      print('UserID saved successfully.');
    } else {
      print('Failed to save userID. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving UserID: $e');
  }
}

void saveSchoolID({required String sessionID, required String schoolID}) async {
  String baseUrl = 'http://' + SERVER_URL;
  Uri uri = Uri.parse('$baseUrl/setSchoolID');

  // Dati da inviare nel corpo della richiesta
  Map<String, dynamic> requestBody = {
    'sessionID': sessionID,
    'schoolID': schoolID,
  };

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('schoolID saved successfully.');
    } else {
      print('Failed to save schoolID. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving schoolID: $e');
  }
}

void saveStartEndDate(
    {required String sessionID,
    required String startDate,
    required String endDate}) async {
  String url = 'http://' +
      SERVER_URL +
      '/setStartEndDate/$sessionID/$startDate/$endDate';

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

void saveSettings(
    {required String sessionID,
    required String distCalls,
    required String distExams}) async {
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

void saveUnavailability(
    {required String sessionID, required Unavail unavail}) async {
  String unavailID = unavail.id;
  String type = unavail.type.toString();
  String name = unavail.professor;
  List<String> dates = unavail.dates.map((e) => e.toString()).toList();
  String url = 'http://' +
      SERVER_URL +
      '/setUnavailability/$sessionID/$unavailID/$type/$name/${dates.join('/')}';

  try {
    final List<Map<String, String>> requestBody =
        dates.map((date) => {'date': date}).toList();

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

void deleteUnavail({required String sessionID, required Unavail unavail}) async {
  String unavailID = unavail.id;
  String url = 'http://' + SERVER_URL + '/setUserID/$sessionID/$unavailID';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      print('UserID saved successfully.');
    } else {
      print('Failed to save userID. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving UserID: $e');
  }
}


void startOptimization({required String sessionID}) async {
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
      print(response
          .body); // Stampa il corpo della risposta per verificare i dati ricevuti
      final dynamic responseData = json.decode(response.body);
      print(responseData);
      final List<String> sessionIDs =
          List<String>.from(responseData.map((item) => item.toString()));
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

Future<Map<String, dynamic>> getSessionData({required String sessionId}) async {
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
