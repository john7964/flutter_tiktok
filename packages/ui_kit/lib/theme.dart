import 'package:flutter/material.dart';
import 'package:ui_kit/typography.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  typography: Typography(
    white: whiteCupertino,
    black: blackCupertino,
    englishLike: englishLike,
    dense: dense,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.amber
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
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.amber
  ),
);
