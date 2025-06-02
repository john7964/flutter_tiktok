import 'package:flutter/material.dart';
import 'package:zuzu/views_integration/login.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamilyFallback: ["PingFang SC"]
          )
        )
      ),
        themeMode: ThemeMode.dark, home: LoginIntegration());
  }
}
