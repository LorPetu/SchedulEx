import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:schedulex_webapp/LoginPage.dart';
import 'package:schedulex_webapp/SessionPage.dart';
import 'package:schedulex_webapp/Settingspage.dart';
import 'package:schedulex_webapp/model/ProblemSessionState.dart';
import 'package:schedulex_webapp/model/UnavailState.dart';
import 'package:schedulex_webapp/model/UserState.dart';
import 'package:schedulex_webapp/CalendarPage.dart';
import 'package:schedulex_webapp/SelectPage.dart';
import 'package:schedulex_webapp/Unavailpage.dart';

void main() {
  runApp(const MyApp());
}

//Main widget that contains all, in here we defined the routing of our webapp
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
        ),
        ChangeNotifierProxyProvider<UserState, ProblemSessionState>(
          create: (context) => ProblemSessionState(),
          update: (context, appState, problemSessionState) {
            if (problemSessionState == null) {
              throw ArgumentError.notNull('problemSessionState');
            }
            problemSessionState.appState = appState;
            return problemSessionState;
          },
        ),
        ChangeNotifierProxyProvider<ProblemSessionState, UnavailState>(
          create: (context) => UnavailState(),
          update: (context, session, unavailState) {
            if (unavailState == null) {
              throw ArgumentError.notNull('unavailState');
            }
            unavailState.sessionState = session;
            return unavailState;
          },
        ),
      ],
      //create: (context) => MyAppState(),
      child: MaterialApp.router(
        title: 'SchedulEx',
        routerConfig: router(),
      ),
    );
  }
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/select',
        builder: (context, state) => const SelectPage(),
        routes: [
          GoRoute(
            path: 'session',
            builder: (context, state) => const ProblemSessionPage(),
          ),
          GoRoute(
            path: 'unavail',
            builder: (context, state) => const UnavailPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'calendar',
            builder: (context, state) => const CalendarPage(),
          )
        ],
      ),
    ],
  );
}
