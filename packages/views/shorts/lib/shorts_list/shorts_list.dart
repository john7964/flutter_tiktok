import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/shorts_bloc.dart';
import 'package:shorts_view/core/video_aspect_ratio.dart';
import 'package:shorts_view/search/search_pages.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';
import 'package:ui_kit/media_certificate/navigator_media_certificate.dart';
import 'package:ui_kit/route/draggable_route.dart';

final List<String> videoSource = [
  "https://media.istockphoto.com/id/1448644808/zh/影片/vertical-drone-shot-pulling-back-from-st-georges-episcopal-church-and-stuyvesant-square-park-in.mp4?s=mp4-640x640-is&k=20&c=6cniiZb7DqwXTNsT7m2OQWwIz2nSjf1KLbtdFMseL4s=",
  "https://videos.pexels.com/video-files/2785536/2785536-uhd_1440_2560_25fps.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
];

class ShortsList extends StatefulWidget {
  const ShortsList({super.key});

  @override
  State<ShortsList> createState() => _ShortsListState();
}

class _ShortsListState extends State<ShortsList>
    with AutomaticKeepAliveClientMixin, MediaCertificationConsumer {
  final PlayListBloc playList = PlayListBloc(sources: videoSource);
  final List<GlobalKey<ResizedRouteTarget>> videoTargetKeys =
      videoSource.map((_) => GlobalKey<ResizedRouteTarget>()).toList();

  GlobalKey<ResizedRouteTarget>? get currentKey => videoTargetKeys[playList.state.playingIndex!];

  void handleTapVideoItem(int index) {
    playList.add(UpdatedPlayingIndexEvent(index));
    final Route route = DraggableResizedRoute(
      getTarget: () => currentKey!.currentState!,
      builder: (context) => NavigatorMediaCertificateScope(
        route: ModalRoute.of(context)!,
        child: BlocProvider.value(value: playList, child: SearchPages()),
      ),
    );
    Navigator.of(context).push(route);
  }

  bool handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    if (!(ModalRoute.isCurrentOf(context) ?? true) || notification.depth != 0) {
      return false;
    }

    RenderBox scrollRenderBox = notification.context!.findRenderObject()! as RenderBox;
    for (int index = 0; index < videoTargetKeys.length; index++) {
      final GlobalKey key = videoTargetKeys[index];
      if (key.currentContext?.findRenderObject() != null) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero, ancestor: scrollRenderBox);
        if (offset.dy >= 0.0 && offset.dy < scrollRenderBox.size.height) {
          playList.add(UpdatedPlayingIndexEvent(index));
          return false;
        }
      }
    }

    playList.add(UpdatedPlayingIndexEvent(null));
    return false;
  }

  @override
  void didChangeDependencies() {
    playList.add(UpdateCertificationConsumer(consumer: this));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final SliverChildDelegate childrenDelegate = SliverChildBuilderDelegate((context, index) {
      if (index >= playList.state.players.length) {
        return null;
      }

      final Widget child = GestureDetector(
        onTap: () => handleTapVideoItem(index),
        child: ShortListItem(videoTargetKey: videoTargetKeys[index]),
      );

      return BlocBuilder<PlayListBloc, PlayListState>(
        buildWhen: (previous, current) => previous.players[index] != current.players[index],
        builder: (BuildContext context, PlayListState state) {
          return BlocProvider.value(value: state.players[index], child: child);
        },
      );
    });

    final Widget body = BlocProvider.value(
      value: playList,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: handleScrollUpdateNotification,
        child: CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverSafeArea(sliver: SliverList(delegate: childrenDelegate)),
          ],
        ),
      ),
    );
    return body;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    playList.close();
    super.dispose();
  }
}

class ShortListItem extends StatefulWidget {
  const ShortListItem({super.key, required this.videoTargetKey});

  final GlobalKey<ResizedRouteTarget> videoTargetKey;

  @override
  State<ShortListItem> createState() => _ShortListItemState();
}

class _ShortListItemState extends State<ShortListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(width: 40, height: 40, color: Colors.amber),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("宅男追剧", style: TextTheme.of(context).titleMedium),
                  Text("2024.6.15", style: TextTheme.of(context).labelMedium)
                ],
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz_sharp))
            ],
          ),
          SizedBox(height: 12),
          Text(
            "悬崖01男人用来接头的墨镜居然被人摔碎了，任长春离奇暴毙！周乙有危险了",
            style: TextTheme.of(context).bodyMedium!.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          VideoFractionalTarget(key: widget.videoTargetKey),
          SizedBox(height: 16),
          IconTheme(
            data: IconThemeData(size: 20),
            child: Row(
              children: [
                Row(
                  children: [Icon(CupertinoIcons.heart), SizedBox(width: 4), Text("1.9万")],
                ),
                Spacer(),
                Row(
                  children: [Icon(CupertinoIcons.heart), SizedBox(width: 4), Text("1.9万")],
                ),
                Spacer(),
                Row(
                  children: [Icon(CupertinoIcons.heart), SizedBox(width: 4), Text("1.9万")],
                ),
                Spacer(),
                Row(
                  children: [Icon(CupertinoIcons.heart), SizedBox(width: 4), Text("1.9万")],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class VideoFractionalTarget extends StatefulWidget {
  const VideoFractionalTarget({super.key});

  @override
  State<VideoFractionalTarget> createState() => _VideoFractionalTargetState();
}

class _VideoFractionalTargetState extends State<VideoFractionalTarget> with ResizedRouteTarget {
  double opacity = 1.0;

  @override
  void didStartFraction() {
    setState(() {
      opacity = 0.0;
    });
  }

  @override
  void didUpdateFraction(double fraction) {
    super.didUpdateFraction(fraction);
    final double opacity = fraction == 0.0 ? 1.0 : 0.0;
    if (opacity != this.opacity) {
      setState(() {
        this.opacity = opacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 150, maxHeight: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: const VideoAspectRatio(),
        ),
      ),
    );
  }
}
