import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui_kit/typography.dart';
import 'package:zuzu/views_integration/login.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';

class App extends StatelessWidget {
  App({super.key});

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    typography: Typography(
      white: whiteCupertino,
      black: blackCupertino,
      englishLike: englishLike,
      dense: dense,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    typography: Typography(
      white: whiteCupertino,
      black: blackCupertino,
      englishLike: englishLike,
      dense: dense,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: Locale('zh'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('zh'), Locale("en")],
      themeMode: ThemeMode.light,
      home: LoginIntegration(),
    );
  }
}
