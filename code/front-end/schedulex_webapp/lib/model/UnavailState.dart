import 'package:flutter/material.dart';
import 'package:schedulex_webapp/model/UserState.dart';
//import 'package:schedulex_webapp/utils.dart';

class UnavailState extends ChangeNotifier {
  late UserState appState;

  String? id;
  int type = 0;
  String name = '';
  List<DateTime> dates = [];
}
