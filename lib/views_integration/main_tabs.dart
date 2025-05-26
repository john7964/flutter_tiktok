import 'package:create_short_view/create_short_view.dart';
import 'package:flutter/widgets.dart';
import 'package:main_tabs_view/main_tabs.dart';
import 'package:zuzu/views_integration/mall.dart';
import 'package:zuzu/views_integration/me.dart';
import 'package:zuzu/views_integration/message.dart';
import 'package:zuzu/views_integration/shorts.dart';

class MainTabsViewIntegration extends StatefulWidget {
  const MainTabsViewIntegration({super.key});

  @override
  State<StatefulWidget> createState() => MainTabsViewIntegrationState();
}

class MainTabsViewIntegrationState extends State<MainTabsViewIntegration> with RouteAware {
  void handleTapCreate(BuildContext context) {
    Navigator.of(context).push(CreateShortView.route());
  }

  @override
  Widget build(BuildContext context) {
    return MainTabsView(
      showBottomBar: true,
      showTopBar: true,
      mall: MallViewIntegration(),
      message: MessageViewIntegration(),
      me: MeViewIntegration(),
      onPressCreate: (_) => handleTapCreate(context),
      recommendedShorts: ShortsIntegration(),
      friendShorts: ShortsIntegration(),
      subscribedShorts: ShortsIntegration(),
    );
  }
}
