import 'package:flutter/material.dart';
import 'package:ui_kit/theme/typography.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  typography: Typography(
    white: whiteCupertino,
    black: blackCupertino,
    englishLike: englishLike,
    dense: dense,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.amber),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    toolbarHeight: 40,
    scrolledUnderElevation: 0.0,
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
  bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.amber),
);
