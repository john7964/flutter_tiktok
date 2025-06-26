import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:main_tabs_view/main_tabs.dart';
import 'package:message_view/chat_list/chat_list.dart';
import 'package:provider/provider.dart';
import 'package:shorts_view/shorts_view.dart';
import 'package:user/me_view.dart';
import 'package:view_integration/message_provider.dart';
import 'package:zuzu/views_integration/login.dart';
import 'package:ui_kit/theme/typography.dart';

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
    return MultiProvider(
      providers: [
        Provider(create: (_) => ShortsDelegateImpl.instance),
        Provider(create: (_) => mainTabsDelegate),
        Provider(create: (_) => userDelegate),
        Provider<MessageDelegate>(create: (_) => MessageDelegateImpl()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
