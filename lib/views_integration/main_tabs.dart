import 'package:create_short_view/create_short_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:main_tabs_view/main_tabs.dart';
import 'package:ui_kit/media_certificate/navigator_media_certificate.dart';
import 'package:zuzu/views_integration/mall.dart';
import 'package:zuzu/views_integration/me.dart';
import 'package:zuzu/views_integration/message.dart';
import 'package:zuzu/views_integration/shorts.dart';
import 'package:shorts_view/search/search_result.dart';

class MainTabsViewIntegration extends StatefulWidget {
  const MainTabsViewIntegration({super.key});

  @override
  State<StatefulWidget> createState() => MainTabsViewIntegrationState();
}

class MainTabsViewIntegrationState extends State<MainTabsViewIntegration> {
  void handleTapCreate() {
    Navigator.of(context).push(CreateShortView.route());
  }

  @override
  Widget build(BuildContext context) {
    late final Widget shorts = ShortsIntegration();

    return MainTabsView(
      mall: MallViewIntegration(),
      message: MessageViewIntegration(),
      me: MeViewIntegration(),
      onPressCreate: handleTapCreate,
      recommendedShorts: shorts,
      friendShorts: shorts,
      subscribedShorts: shorts,
      onPressSearch: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) {
              return NavigatorMediaCertificateScope(
                route: ModalRoute.of(context)!,
                child: SearchResult(),
              );
            },
          ),
        );
      },
    );
  }
}
