import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/root_navigator.dart';
import 'package:zuzu/bloc/authed_user.dart';
import 'package:zuzu/views_integration/main_tabs.dart';

class UserRoot extends StatefulWidget {
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  const UserRoot({super.key, required this.userKey});

  final Key userKey;

  @override
  State<UserRoot> createState() => _UserRootState();
}

class _UserRootState extends State<UserRoot> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthedUserBloc(widget.userKey),
      child: RootNavigator(
        routeObserver: UserRoot.routeObserver,
        onGenerateRoute: (context) {
          return MaterialPageRoute(builder: (context) => MainTabsViewIntegration());
        },
      ),
    );
  }
}
