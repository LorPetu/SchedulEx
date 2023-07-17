import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'utils.dart';

const SERVER_URL = "127.0.0.1:5000";

void saveUserID({required String sessionID, required String userID}) async {
  String url = 'http://$SERVER_URL/setUserID/$sessionID/$userID';

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
  String baseUrl = 'http://$SERVER_URL';
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
  String url =
      'http://$SERVER_URL/setStartEndDate/$sessionID/$startDate/$endDate';

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
      'http://$SERVER_URL/setSettings/$sessionID/$distCalls/$distExams';

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

Future<dynamic> saveUnavailability(
    {required String sessionID,
    required String unavailID,
    required Map<String, dynamic> payload}) async {
  String url = 'http://$SERVER_URL/saveUnavailability/';
  String txt = 'unavailability';
  String action = 'save';

  //List<String> dates = unavail.dates.map((e) => e.toString()).toList();

  Map<String, String> requestbody = {};
  requestbody.addAll({'sessionID': sessionID});

  if (unavailID.isNotEmpty) {
    requestbody.addAll({'unavailID': unavailID});
  }

  debugPrint('Methods: SaveUnavailability requestbody= $requestbody');

  payload.forEach((k, v) => requestbody.addAll({k: v.toString()}));

  debugPrint('Methods: SaveUnavailability payload = $payload');
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestbody),
    );

    if (response.statusCode == 200) {
      print('$txt $action successfully.');
      //print(response.body);

      return jsonDecode(response.body);
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

void deleteUnavailability(
    {required String sessionID, required Unavail unavail}) async {
  String unavailID = unavail.id;
  String url = 'http://$SERVER_URL/delete_unavail/$sessionID/$unavailID';

  try {
    final response = await http.get(Uri.parse(url));
    print(response.request);

    if (response.statusCode == 200) {
      print('unavail deleted successfully.');
    } else {
      print('Failed to save userID. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving UserID: $e');
  }
}

void deleteSession({required String sessionID}) async {
  String url = 'http://$SERVER_URL/deleteSession/$sessionID';

  try {
    final response = await http.get(Uri.parse(url));
    print(url);

    if (response.statusCode == 200) {
      print('Session $sessionID deleted successfully.');
    } else {
      print('Failed to start schedule. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while starting scheduling: $e');
  }
}

void startOptimization({required String sessionID}) async {
  String url = 'http://$SERVER_URL/startOptimization/$sessionID';

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

Future<dynamic> saveSession(
    {required String sessionID, required Map<String, dynamic> payload}) async {
  String url = 'http://$SERVER_URL/saveSession/';
  String txt = 'Session';
  String action = 'save';
  Map<String, String> requestbody = {};

  if (sessionID.isNotEmpty) {
    requestbody.addAll({'sessionID': sessionID});
  }

  print(requestbody);

  payload.forEach((k, v) => requestbody.addAll({k: v.toString()}));

  print(payload);
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestbody),
    );

    if (response.statusCode == 200) {
      print('$txt $action successfully.');
      //print(response.body);

      return jsonDecode(response.body);
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

//This is used in the Select Page
Future<List<ProblemSession>> getSessionList() async {
  String url = 'http://$SERVER_URL/getSessionList';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('getSessionList_OK.');
      print(response.body);
      final dynamic responseData = json.decode(response.body);
      final List<ProblemSession> sessions =
          responseData.map<ProblemSession>((item) {
        return ProblemSession(
          id: item['id'],
          school: item['school'] ?? '',
          status: item['status'] ?? '',
          description: item['description'] ?? '',
          user: item['users'] ?? '',
        );
      }).toList();
      return sessions;
    } else {
      print('Failed getSessionList. Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Exception occurred for getSessionList: $e');
    return [];
  }
}

//This is used in the Problem Session Page
Future<ProblemSession> getSessionData({required String sessionId}) async {
  String url = 'http://$SERVER_URL/getSessionData/$sessionId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      //print('getSessionData_OK.');
      final responseData = json.decode(response.body);
      Map<String, dynamic> unavailData = responseData['unavailList'];
      print(unavailData);
      List<Unavail> results = [];

      for (var entry in unavailData.entries) {
        //debugPrint('child of $sessionId' + entry.key);
        String id = entry.key;
        dynamic data = entry.value;

        if (data != '') {
          int type = (data['type'] != null && data['type'] != '')
              ? int.tryParse(data['type'].toString()) ?? 0
              : 0;

          String name = data['name'] ?? '';
          List<DateTime> dates = (data['dates'] != null)
              ? List<DateTime>.from(
                  data['dates'].map((dateString) => DateTime.parse(dateString)))
              : [];

          results.add(Unavail(id: id, type: type, name: name, dates: dates));
        } else {
          results.add(Unavail(id: id, type: 0, name: 'empty', dates: []));
        }
      }

      return ProblemSession(
          id: sessionId,
          school: responseData['school'],
          startDate: DateTime.parse(responseData['startDate']),
          endDate: DateTime.parse(responseData['endDate']),
          status: responseData['endDate'],
          unavailList: results);
    } else {
      print('Failed getSessionData. Error: ${response.statusCode}');
      throw Exception('Failed getSessionData. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getSessionData: $e');
    throw Exception('Exception occurred for getSessionData: $e');
  }
}

//This is used in the UnavailPage
Future<dynamic> getUnavailData(
    {required String sessionId, required String unavailID}) async {
  String url = 'http://$SERVER_URL/getUnavailData/$sessionId/$unavailID';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.isEmpty) {
        // Return a default empty Unavail object
        return Unavail(id: unavailID, type: 0, name: '', dates: []);
      } else {
        int type = (responseData['type'] != null)
            ? int.parse(responseData['type'].toString())
            : 0;
        String name = responseData['name'] ?? '';
        List<DateTime> dates = (responseData['dates'] != null)
            ? List<DateTime>.from(responseData['dates']
                .map((dateString) => DateTime.parse(dateString)))
            : [];
        String id = unavailID;
        return Unavail(id: id, type: type, name: name, dates: dates);
      }
    } else {
      print('Failed getUnavailData. Error: ${response.statusCode}');
      throw Exception('Failed getUnavailData. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getUnavailData: $e');
    throw Exception('Exception occurred for getUnavailData: $e');
  }
}

Future<void> downloadExcel() async {
  var url = 'https://$SERVER_URL/Database_esami.xlsx';
  var response = await http.get(Uri.parse(url));
  var bytes = response.bodyBytes;
  await File('Database_esami.xlsx').writeAsBytes(bytes);
}

/*
Future<List<Unavail>> getSessionData({required String sessionId}) async {
  String url = 'http://$SERVER_URL/getSessionData/$sessionId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      //print('getSessionData_OK.');
      final responseData = json.decode(response.body);
      Map<String, dynamic> unavailData = responseData['unavailList'];
      print(unavailData);
      List<Unavail> results = [];

      for (var entry in unavailData.entries) {
        //debugPrint('child of $sessionId' + entry.key);
        String id = entry.key;
        dynamic data = entry.value;

        if (data != '') {
          int type = (data['type'] != null && data['type'] != '')
              ? int.tryParse(data['type'].toString()) ?? 0
              : 0;

          String name = data['name'] ?? '';
          List<DateTime> dates = (data['dates'] != null)
              ? List<DateTime>.from(
                  data['dates'].map((dateString) => DateTime.parse(dateString)))
              : [];

          results.add(Unavail(id: id, type: type, name: name, dates: dates));
        } else {
          results.add(Unavail(id: id, type: 0, name: 'empty', dates: []));
        }
      }

      return {'info': ProblemSession(id: sessionId, school: responseData['school']),'list':results};
    } else {
      print('Failed getSessionData. Error: ${response.statusCode}');
      throw Exception('Failed getSessionData. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getSessionData: $e');
    throw Exception('Exception occurred for getSessionData: $e');
  }
}*/