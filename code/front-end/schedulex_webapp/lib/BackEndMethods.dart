import 'dart:async';
//import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'utils.dart';

const SERVER_URL = "127.0.0.1:5000";

Future<void> saveUserID(
    {required String sessionID, required String userID}) async {
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

Future<void> saveSchoolID(
    {required String sessionID, required String schoolID}) async {
  String baseUrl = 'http://$SERVER_URL';
  Uri uri = Uri.parse('$baseUrl/setSchoolID');

  // build the request body with the specifie
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

Future<void> saveStartEndDate(
    {required String sessionID,
    required String startDate,
    required String endDate}) async {
  String url =
      'http://$SERVER_URL/setStartEndDate/$sessionID/$startDate/$endDate';

  try {
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Session dates saved successfully.');
    } else {
      print('Failed to save session dates. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while saving session dates: $e');
  }
}

Future<void> saveSettings(
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

  Map<String, String> requestbody = {};
  requestbody.addAll({'sessionID': sessionID});

  if (unavailID.isNotEmpty) {
    requestbody.addAll({'unavailID': unavailID});
  }

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

Future<List<DateTime>> addDatesToUnavail(
    {required String sessionID,
    required String unavailID,
    required List<DateTime> newDates}) async {
  String url = 'http://$SERVER_URL/saveUnavailability/';
  String txt = 'unavailability DATES';
  String action = 'save';

  Map<String, String> requestbody = {};
  requestbody.addAll({'sessionID': sessionID});

  if (unavailID.isNotEmpty) {
    requestbody.addAll({'unavailID': unavailID});
  }
  // Date list conversion to string format suitable for the request payload
  String newdatesStr = newDates.map(
    (date) {
      return date.toString();
    },
  ).join('/');
  requestbody.addAll({'dates': newdatesStr});

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestbody),
    );

    if (response.statusCode == 200) {
      print('$txt $action successfully.');

      //conversion of the response in a suitable type and check each item if is already a Datetime or not
      List<DateTime> dateTimeList =
          (jsonDecode(response.body)['value']['dates'] as List<dynamic>)
              .map((dynamic item) {
        if (item is DateTime) {
          return item;
        } else if (item is String) {
          return DateTime.parse(item);
        }
        // Handle other cases if needed
        throw const FormatException('Invalid date format');
      }).toList();

      return dateTimeList;
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
  return [];
}

Future<void> deleteDateToUnavail(
    {required String sessionID,
    required String unavailID,
    required DateTime datetoDelete}) async {
  String url = 'http://$SERVER_URL/deleteUnavailabilityDate';
  String txt = 'unavailability DATE';
  String action = 'delete';

  Map<String, String> requestbody = {};

  if (sessionID.isNotEmpty) {
    requestbody.addAll({'sessionID': sessionID});
  }

  if (unavailID.isNotEmpty) {
    requestbody.addAll({'unavailID': unavailID});
  }
  requestbody.addAll({'date': datetoDelete.toString()});

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestbody),
    );

    if (response.statusCode == 200) {
      print('$action $txt successfully.');
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

Future<void> deleteUnavailability(
    {required String sessionID, required Unavail unavail}) async {
  String unavailID = unavail.id;
  String url = 'http://$SERVER_URL/delete_unavail/$sessionID/$unavailID';

  try {
    final response = await http.get(Uri.parse(url));
    print(response.request);

    if (response.statusCode == 200) {
      print('unavail deleted successfully.');
    } else {
      print('Failed to delete unavail. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while delete unavail: $e');
  }
}

Future<void> deleteSession({required String sessionID}) async {
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
    print('Exception occurred while deleting session $sessionID: $e');
  }
}

Future<void> startOptimization({required String sessionID}) async {
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

Future<Map<String, dynamic>?> getStatus({required String sessionID}) async {
  String url = 'http://$SERVER_URL/askStatus/$sessionID';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Get status successfully.');
      return jsonDecode(response.body);
    } else {
      print('Failed to get status. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while getting status: $e');
  }
  return null;
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

  payload.forEach((k, v) => requestbody.addAll({k: v.toString()}));

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestbody),
    );

    if (response.statusCode == 200) {
      print('$txt $action successfully.');

      return jsonDecode(response.body);
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

Future<List<ProblemSession>> getSessionList() async {
  String url = 'http://$SERVER_URL/getSessionList';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      final List<ProblemSession> sessions =
          responseData.map<ProblemSession>((item) {
        return ProblemSession(
            id: item['id'],
            school: item['school'] ?? '',
            status: item['status'] ?? '',
            description: item['description'] ?? '',
            user: item['users'] ?? '',
            startDate: DateTime.tryParse(item['startDate'].toString()),
            endDate: DateTime.tryParse(item['endDate'].toString()));
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

Future<dynamic> getSessionData({required String sessionID}) async {
  String url = 'http://$SERVER_URL/getSessionData/$sessionID';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('getSessionData_OK.');
      final responseData = json.decode(response.body);
      print(responseData);
      List<Unavail> results = [];
      //Check if exists a unavailList and use a map to process it.
      if (responseData['unavailList'] != null) {
        Map<String, dynamic> unavailData = responseData['unavailList'];

        for (var entry in unavailData.entries) {
          String id = entry
              .key; //Each id is defined by the firebase databse and it's the key of each child
          dynamic data =
              entry.value; //while the unavail data is in the value of the map

          //Check for all unavail properties and corresponding assegnation and type conversion
          if (data != null && data.isNotEmpty) {
            int type = (data['type'] != null &&
                    data['type'] is String &&
                    data['type'] != '')
                ? int.tryParse(data['type'].toString()) ?? 0
                : 0; //default 'professor'

            String name = (data['name'] != null && data['name'] is String)
                ? data['name']
                : ''; //default is empty string

            List<DateTime> dates = (data['dates'] != null &&
                    data['dates'] is List)
                ? List<DateTime>.from(data['dates']!.map(
                    (dateString) => DateTime.tryParse(dateString.toString())))
                : []; //default is an empty list

            results.add(Unavail(
              id: id,
              type: type,
              name: name,
              dates: dates,
            ));
          } else {
            results.add(Unavail(id: id, type: 0, name: 'empty', dates: []));
          }
        }
      } else {
        results = [];
      }

      DateTime? startDate = responseData['startDate'] != null
          ? DateTime.tryParse(responseData['startDate'].toString())
          : null;
      DateTime? endDate = responseData['endDate'] != null
          ? DateTime.tryParse(responseData['endDate'].toString())
          : null;

      Map<String, dynamic> settingsData = responseData['settings'] != null
          ? Map<String, dynamic>.from(responseData['settings'])
          : {};
      //Return a map object to differently process settings data and ProblemSession relative one
      return {
        'problemsession': ProblemSession(
          id: sessionID,
          school: responseData['school'] ?? '',
          status: responseData['status'],
          description: responseData['description'] ?? '',
          startDate: startDate,
          endDate: endDate,
          unavailList: results,
        ),
        'settings': settingsData
      };
    } else {
      print('Failed getSessionData. Error: ${response.statusCode}');
      throw Exception('Failed getSessionData. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getSessionData: $e');
    throw Exception('Exception occurred for getSessionData: $e');
  }
}

Future<dynamic> getUnavailData(
    {required String sessionID, required String unavailID}) async {
  String url = 'http://$SERVER_URL/getUnavailData/$sessionID/$unavailID';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.isEmpty) {
        // Return a default empty Unavail object
        return Unavail(id: unavailID, type: 0, name: '', dates: []);
      } else {
        //unavail is not empty, so its properties is updated
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

Future<List<String>> getProfessorList() async {
  String url = 'http://$SERVER_URL/getProfessorList';

  try {
    final response = await http.get(Uri.parse(url));
    print(response.request);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        List<String> professorList =
            responseData.map((dynamic item) => item.toString()).toList();
        return professorList;
      } else {
        throw Exception('Invalid response format: Expected List<dynamic>.');
      }
    } else {
      print('Failed getProfessorList Error: ${response.statusCode}');
      throw Exception('Failed getProfessorList. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getProfessorList: $e');
    throw Exception('Exception occurred for getProfessorList: $e');
  }
}

Future<List<Exam>> getExamList() async {
  String url = 'http://$SERVER_URL/getExamList';

  try {
    final response = await http.get(Uri.parse(url));
    print(response.request);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        List<Exam> professorList = responseData
            .map((dynamic item) =>
                item = Exam(item['id'], item['name'], item['cds'] ?? '', []))
            .toList();
        print(professorList);
        return professorList;
      } else {
        throw Exception('Invalid response format: Expected List<dynamic>.');
      }
    } else {
      print('Failed getProfessorList Error: ${response.statusCode}');
      throw Exception('Failed getProfessorList. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred for getProfessorList: $e');
    throw Exception('Exception occurred for getProfessorList: $e');
  }
}

Future<void> setSettings(
    {required String sessionID, required Map<String, dynamic> payload}) async {
  String url = 'http://$SERVER_URL/setSettings/';
  String txt = 'Settings set';
  String action = 'set';
  //The request must be expressed as string
  payload.addAll({'sessionID': sessionID});

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(Map<String, Object>.from(payload)),
    );

    if (response.statusCode == 200) {
      print('$txt $action successfully.');
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

Future<dynamic> getJsonResults(sessionID) async {
  final url = 'http://$SERVER_URL/getJSONresults/$sessionID';

  String txt = 'JSON';
  String action = 'get';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('$txt $action successfully.');

      return jsonDecode(response.body);
    } else {
      print('Failed to $action $txt. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while $action $txt: $e');
  }
}

Future<String?> downloadExcel(String sessionID) async {
  final String url = 'http://$SERVER_URL/downloadExcel/$sessionID';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // File download successful.
      final String fileName = 'CalendarSession$sessionID.xlsx';
      final File file = File('$FOLDER_PATH\\$fileName');

      await file.writeAsBytes(response.bodyBytes);

      return 'File downloaded and saved successfully in folder: $FOLDER_PATH.';
    } else {
      return 'Failed to download the file. Status code: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}
