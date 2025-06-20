import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/shorts_bloc.dart';
import 'package:shorts_view/shorts_page/short_scaffold.dart';
import 'package:ui_kit/page_view.dart';
import 'package:ui_kit/route/draggable_route.dart';
import 'package:ui_kit/theme.dart';
import 'package:ui_kit/media_certificate/indexed_media_certificate.dart';
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

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> with TickerProviderStateMixin {
  late final PageController tabController = PageController(
    initialPage: shorts.state.lastPlayingIndex,
  );
  late final ValueNotifier<int> currentPage = ValueNotifier(tabController.initialPage)
    ..addListener(handleCurrentPageChanged);

  late ShortPlayersBloc? parentShorts;
  ShortPlayersBloc? _localShorts;

  ShortPlayersBloc get localShorts => _localShorts ??= ShortPlayersBloc(sources: videoSource);

  ShortPlayersBloc get shorts => parentShorts ?? localShorts;

  bool handleScrollNotification(ScrollEndNotification notification) {
    if (notification.depth == 0) {
      currentPage.value = tabController.page!.round();
    }
    return false;
  }

  void handleCurrentPageChanged() {
    shorts.add(UpdatedPlayingIndexEvent(currentPage.value));
  }

  @override
  void didChangeDependencies() {
    try {
      parentShorts = context.watch<ShortPlayersBloc>();
    } on ProviderNotFoundException {
      parentShorts = null;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final SliverChildDelegate childrenDelegate = SliverChildBuilderDelegate((context, index) {
      if (index >= shorts.state.players.length) {
        return null;
      }
      final Widget child = IndexedMediaCertificateScope(
        index: index,
        child: VideoSkeleton(),
      );

      return BlocBuilder<ShortPlayersBloc, ShortsState>(
        buildWhen: (previous, current) => previous.players[index] != current.players[index],
        builder: (BuildContext context, ShortsState state) {
          return BlocProvider.value(value: state.players[index], child: child);
        },
      );
    });

    final videos = BlocProvider.value(
      value: shorts,
      child: ColoredBox(
        color: Colors.black,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: handleScrollNotification,
          child: IndexedMediaCertificateDispatcher(
            controller: currentPage,
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

    return Theme(
      data: darkTheme,
      child: Material(
        type: MaterialType.transparency,
        child: ValueListenableBuilder(
          valueListenable: DraggableResizedRoute.maybeOf(context)?.fraction ?? ValueNotifier(1.0),
          builder: (context, value, child) {
            final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
            final EdgeInsets padding = EdgeInsets.only(bottom: bottomPadding * value);
            return Padding(padding: padding, child: videos);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    _localShorts?.close();
    super.dispose();
  }
}
