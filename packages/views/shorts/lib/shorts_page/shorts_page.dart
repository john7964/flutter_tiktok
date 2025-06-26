import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/shorts_bloc.dart';
import 'package:shorts_view/shorts_page/short_scaffold.dart';
import 'package:ui_kit/appbar_manager.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';
import 'package:ui_kit/page_view.dart';
import 'package:ui_kit/route/draggable_route.dart';
import 'package:ui_kit/theme/theme.dart';
import 'package:provider/provider.dart';

final List<String> videoSource = [
  "https://media.istockphoto.com/id/1448644808/zh/影片/vertical-drone-shot-pulling-back-from-st-georges-episcopal-church-and-stuyvesant-square-park-in.mp4?s=mp4-640x640-is&k=20&c=6cniiZb7DqwXTNsT7m2OQWwIz2nSjf1KLbtdFMseL4s=",
  "https://videos.pexels.com/video-files/2785536/2785536-uhd_1440_2560_25fps.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
];

class ShortsPages extends StatefulWidget {
  const ShortsPages({super.key, this.appBar});

  final Widget? appBar;

  @override
  State<ShortsPages> createState() => _ShortsPagesState();
}

class _ShortsPagesState extends State<ShortsPages> with AppBarManager {
  late bool showAppbar = true;

  @override
  void changeAppBar({bool? top, bool? bottom}) {
    if (top != null && top != showAppbar) {
      setState(() => showAppbar = top);
    }
    super.changeAppBar(top: top, bottom: bottom);
  }

  @override
  Widget build(BuildContext context) {
    final Route route = MaterialPageRoute(builder: (context) {
      return ShortsPagesView();
    });

    final Widget appBar = ValueListenableBuilder(
      valueListenable: DraggableResizedRoute.maybeOf(context)?.animation ?? ValueNotifier(1.0),
      builder: (context, value, child) {
        return Offstage(offstage: value != 1.0 || !showAppbar, child: child);
      },
      child: UnconstrainedBox(constrainedAxis: Axis.horizontal, child: widget.appBar),
    );

    return Theme(
      data: darkTheme,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [Navigator(onGenerateRoute: (settings) => route), appBar],
        ),
      ),
    );
  }
}

class ShortsPagesView extends StatefulWidget {
  const ShortsPagesView({super.key, this.appBar});

  final Widget? appBar;

  @override
  State<ShortsPagesView> createState() => _ShortsPagesViewState();
}

class _ShortsPagesViewState extends State<ShortsPagesView> with MediaCertificationConsumer {
  late final ValueNotifier<int> currentPage = ValueNotifier(tabController.initialPage)
    ..addListener(handleCurrentPageChanged);
  late PlayListBloc? parentPlayList;
  PlayListBloc? _localPlayList;

  PlayListBloc get localPlayList => _localPlayList ??= PlayListBloc(sources: videoSource);

  PlayListBloc get playList => parentPlayList ?? localPlayList;

  late final PageController tabController = PageController(
    initialPage: playList.state.playingIndex ?? 0,
  );

  bool handleScrollNotification(ScrollEndNotification notification) {
    if (notification.depth == 0) {
      currentPage.value = tabController.page!.round();
    }
    return false;
  }

  void handleCurrentPageChanged() {
    playList.add(UpdatedPlayingIndexEvent(currentPage.value));
  }

  @override
  void didChangeDependencies() {
    try {
      parentPlayList = context.watch<PlayListBloc>();
    } on ProviderNotFoundException {
      parentPlayList = null;
    }
    playList.add(UpdateCertificationConsumer(consumer: this));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final SliverChildDelegate childrenDelegate = SliverChildBuilderDelegate((context, index) {
      if (index >= playList.state.players.length) {
        return null;
      }

      return BlocBuilder<PlayListBloc, PlayListState>(
        buildWhen: (previous, current) => previous.players[index] != current.players[index],
        builder: (BuildContext context, PlayListState state) {
          return BlocProvider.value(value: state.players[index], child: const VideoSkeleton());
        },
      );
    });

    final Widget videos = BlocProvider.value(
      value: playList,
      child: ColoredBox(
        color: Colors.black,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: handleScrollNotification,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: PageView2.custom(
              pageSnapping: false,
              physics: const PageFixedDurationScrollPhysics(parent: BouncingScrollPhysics()),
              controller: tabController,
              scrollDirection: Axis.vertical,
              hitTestBehavior: HitTestBehavior.translucent,
              childrenDelegate: childrenDelegate,
            ),
          ),
        ),
      ),
    );

    return LayoutBuilder(builder: (context, constrains) {
      return ValueListenableBuilder(
        valueListenable: DraggableResizedRoute.maybeOf(context)?.animation ?? ValueNotifier(1.0),
        builder: (context, value, child) {
          final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom * value;
          return Column(
            children: [
              SizedBox(
                height: constrains.maxHeight - bottomPadding,
                child: videos,
              ),
              Expanded(
                child: Offstage(offstage: value != 1.0, child: Container(color: Colors.black)),
              )
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    _localPlayList?.close();
    super.dispose();
  }
}
