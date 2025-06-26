import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/root_navigator.dart';
import 'package:view_integration/main_tabs_provider.dart';
import 'package:zuzu/bloc/authed_user.dart';
import 'package:ui_kit/media_certificate/navigator_media_certificate.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();

class UserRoot extends StatefulWidget {
  const UserRoot({super.key, required this.userKey});

  final Key userKey;

  @override
  State<UserRoot> createState() => _UserRootState();
}

class _UserRootState extends State<UserRoot> {
  final CertificateDispatchNavigatorObserver observer = CertificateDispatchNavigatorObserver();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthedUserBloc(widget.userKey),
      child: NavigatorMediaCertificateDispatcher(
        observer: observer,
        child: RootNavigator(
          observers: [observer],
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                return NavigatorMediaCertificateScope(
                  route: ModalRoute.of(context)!,
                  child: context.read<MainTabsDelegate>().mainTabs,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
