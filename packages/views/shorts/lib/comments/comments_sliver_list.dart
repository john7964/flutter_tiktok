import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shorts_view/core/duration.dart';

class CommentEntity {
  final String content;
  final String author;
  final int timestamp;
  final String ipLocation;
  final int likeCount;
  final int dislikeCount;
  final String avatarUrl;
  final int replyCount;
  final bool topLevel;

  CommentEntity({
    required this.avatarUrl,
    required this.content,
    required this.author,
    required this.timestamp,
    required this.ipLocation,
    required this.likeCount,
    required this.dislikeCount,
    this.topLevel = true,
    this.replyCount = 0,
  });
}

List<CommentEntity> comments = [
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=1",
    content: "\uD83D\uDE0A这个视频讲解得非常详细，逻辑清晰易懂，让我对相关知识有了更深入的理解，非常感谢作者的用心制作。",
    author: "小明",
    timestamp: DateTime.now().millisecondsSinceEpoch,
    ipLocation: "北京",
    likeCount: 12,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=2",
    content: "画面很清晰，配乐也很棒，整体观感非常舒服。每次看完都能收获很多新知识，真的很喜欢这个频道。",
    author: "小红",
    timestamp: DateTime.now().millisecondsSinceEpoch - 1000,
    ipLocation: "上海",
    likeCount: 8,
    dislikeCount: 1,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=3",
    content: "学到了很多新知识，希望以后能看到更多类似内容。作者的讲解方式非常适合新手，受益匪浅。",
    author: "阿伟",
    timestamp: DateTime.now().millisecondsSinceEpoch - 2000,
    ipLocation: "广州",
    likeCount: 15,
    dislikeCount: 0,
    replyCount: 5,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=4",
    content: "有些地方还不太明白，能不能再详细解释一下？希望能出一期专门讲解难点的内容，谢谢！",
    author: "小李",
    timestamp: DateTime.now().millisecondsSinceEpoch - 3000,
    ipLocation: "深圳",
    likeCount: 3,
    dislikeCount: 2,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=5",
    content: "内容很有趣，适合新手入门，推荐给朋友们一起看。希望作者继续保持更新，期待更多精彩内容。",
    author: "小王",
    timestamp: DateTime.now().millisecondsSinceEpoch - 4000,
    ipLocation: "杭州",
    likeCount: 10,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=6",
    content: "每次看完都能学到新东西，真的很喜欢这个频道。希望以后能有更多互动环节，增加趣味性。",
    author: "小赵",
    timestamp: DateTime.now().millisecondsSinceEpoch - 5000,
    ipLocation: "成都",
    likeCount: 7,
    dislikeCount: 1,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=7",
    content: "讲解逻辑清晰，配图也很直观，点赞支持一下！希望能多一些实际案例分析，帮助理解。",
    author: "小孙",
    timestamp: DateTime.now().millisecondsSinceEpoch - 6000,
    ipLocation: "重庆",
    likeCount: 9,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=8",
    content: "希望下次能讲讲相关的进阶知识，期待更新！每次都能学到新东西，感谢作者的辛勤付出。",
    author: "小周",
    timestamp: DateTime.now().millisecondsSinceEpoch - 7000,
    ipLocation: "南京",
    likeCount: 6,
    dislikeCount: 1,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=9",
    content: "视频节奏刚刚好，不会觉得拖沓，信息量很大。希望能有更多互动内容，提升观看体验。",
    author: "小吴",
    timestamp: DateTime.now().millisecondsSinceEpoch - 8000,
    ipLocation: "苏州",
    likeCount: 11,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=10",
    content: "有些地方讲得特别生动，容易理解，感谢分享。希望能出一些相关的练习题，方便巩固知识。",
    author: "小郑",
    timestamp: DateTime.now().millisecondsSinceEpoch - 9000,
    ipLocation: "天津",
    likeCount: 5,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=11",
    content: "第一次评论，内容真的很棒，继续加油！希望以后能看到更多高质量的视频，支持作者。",
    author: "小冯",
    timestamp: DateTime.now().millisecondsSinceEpoch - 10000,
    ipLocation: "武汉",
    likeCount: 4,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=12",
    content: "建议增加一些实际案例分析，效果会更好。每次都能学到新知识，感谢作者的无私分享。",
    author: "小陈",
    timestamp: DateTime.now().millisecondsSinceEpoch - 11000,
    ipLocation: "西安",
    likeCount: 3,
    dislikeCount: 1,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=13",
    content: "每次都能学到新知识，感谢作者的无私分享。希望能有更多互动环节，提升学习效果。",
    author: "小褚",
    timestamp: DateTime.now().millisecondsSinceEpoch - 12000,
    ipLocation: "青岛",
    likeCount: 8,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=14",
    content: "内容很实用，已经收藏，准备慢慢学习。希望作者能继续保持更新，带来更多优质内容。",
    author: "小卫",
    timestamp: DateTime.now().millisecondsSinceEpoch - 13000,
    ipLocation: "大连",
    likeCount: 7,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=15",
    content: "讲得很细致，适合零基础的朋友，非常推荐。希望能有更多相关主题的视频，方便系统学习。",
    author: "小蒋",
    timestamp: DateTime.now().millisecondsSinceEpoch - 14000,
    ipLocation: "合肥",
    likeCount: 6,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=16",
    content: "希望能出一些相关的练习题，方便巩固知识。每次看完都觉得收获满满，非常感谢。",
    author: "小沈",
    timestamp: DateTime.now().millisecondsSinceEpoch - 15000,
    ipLocation: "厦门",
    likeCount: 5,
    dislikeCount: 1,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=17",
    content: "视频内容丰富，讲解方式很有趣，容易吸收。希望能有更多互动内容，提升观看体验。",
    author: "小韩",
    timestamp: DateTime.now().millisecondsSinceEpoch - 16000,
    ipLocation: "济南",
    likeCount: 9,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=18",
    content: "每次都能学到新东西，感谢作者的辛勤付出。希望以后能有更多高质量的内容更新。",
    author: "小杨",
    timestamp: DateTime.now().millisecondsSinceEpoch - 17000,
    ipLocation: "哈尔滨",
    likeCount: 10,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=19",
    content: "建议增加字幕，方便听力不好的朋友观看。内容很新颖，和其他视频不太一样，值得一看。",
    author: "小朱",
    timestamp: DateTime.now().millisecondsSinceEpoch - 18000,
    ipLocation: "长春",
    likeCount: 2,
    dislikeCount: 0,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=20",
    content: "内容很新颖，和其他视频不太一样，值得一看。希望作者能继续保持创新，带来更多惊喜。",
    author: "小秦",
    timestamp: DateTime.now().millisecondsSinceEpoch - 19000,
    ipLocation: "福州",
    likeCount: 6,
    dislikeCount: 0,
  ),
];

List<CommentEntity> replyComments = [
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=1",
    content: "\uD83D\uDE0A这个视频讲解得非常详细，逻辑清晰易懂，让我对相关知识有了更深入的理解，非常感谢作者的用心制作。",
    author: "小明",
    timestamp: DateTime.now().millisecondsSinceEpoch,
    ipLocation: "北京",
    likeCount: 12,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=2",
    content: "画面很清晰，配乐也很棒，整体观感非常舒服。每次看完都能收获很多新知识，真的很喜欢这个频道。",
    author: "小红",
    timestamp: DateTime.now().millisecondsSinceEpoch - 1000,
    ipLocation: "上海",
    likeCount: 8,
    dislikeCount: 1,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=3",
    content: "学到了很多新知识，希望以后能看到更多类似内容。作者的讲解方式非常适合新手，受益匪浅。",
    author: "阿伟",
    timestamp: DateTime.now().millisecondsSinceEpoch - 2000,
    ipLocation: "广州",
    likeCount: 15,
    dislikeCount: 0,
    replyCount: 5,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=4",
    content: "有些地方还不太明白，能不能再详细解释一下？希望能出一期专门讲解难点的内容，谢谢！",
    author: "小李",
    timestamp: DateTime.now().millisecondsSinceEpoch - 3000,
    ipLocation: "深圳",
    likeCount: 3,
    dislikeCount: 2,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=5",
    content: "内容很有趣，适合新手入门，推荐给朋友们一起看。希望作者继续保持更新，期待更多精彩内容。",
    author: "小王",
    timestamp: DateTime.now().millisecondsSinceEpoch - 4000,
    ipLocation: "杭州",
    likeCount: 10,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=6",
    content: "每次看完都能学到新东西，真的很喜欢这个频道。希望以后能有更多互动环节，增加趣味性。",
    author: "小赵",
    timestamp: DateTime.now().millisecondsSinceEpoch - 5000,
    ipLocation: "成都",
    likeCount: 7,
    dislikeCount: 1,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=7",
    content: "讲解逻辑清晰，配图也很直观，点赞支持一下！希望能多一些实际案例分析，帮助理解。",
    author: "小孙",
    timestamp: DateTime.now().millisecondsSinceEpoch - 6000,
    ipLocation: "重庆",
    likeCount: 9,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=8",
    content: "希望下次能讲讲相关的进阶知识，期待更新！每次都能学到新东西，感谢作者的辛勤付出。",
    author: "小周",
    timestamp: DateTime.now().millisecondsSinceEpoch - 7000,
    ipLocation: "南京",
    likeCount: 6,
    dislikeCount: 1,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=9",
    content: "视频节奏刚刚好，不会觉得拖沓，信息量很大。希望能有更多互动内容，提升观看体验。",
    author: "小吴",
    timestamp: DateTime.now().millisecondsSinceEpoch - 8000,
    ipLocation: "苏州",
    likeCount: 11,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=10",
    content: "有些地方讲得特别生动，容易理解，感谢分享。希望能出一些相关的练习题，方便巩固知识。",
    author: "小郑",
    timestamp: DateTime.now().millisecondsSinceEpoch - 9000,
    ipLocation: "天津",
    likeCount: 5,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=11",
    content: "第一次评论，内容真的很棒，继续加油！希望以后能看到更多高质量的视频，支持作者。",
    author: "小冯",
    timestamp: DateTime.now().millisecondsSinceEpoch - 10000,
    ipLocation: "武汉",
    likeCount: 4,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=12",
    content: "建议增加一些实际案例分析，效果会更好。每次都能学到新知识，感谢作者的无私分享。",
    author: "小陈",
    timestamp: DateTime.now().millisecondsSinceEpoch - 11000,
    ipLocation: "西安",
    likeCount: 3,
    dislikeCount: 1,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=13",
    content: "每次都能学到新知识，感谢作者的无私分享。希望能有更多互动环节，提升学习效果。",
    author: "小褚",
    timestamp: DateTime.now().millisecondsSinceEpoch - 12000,
    ipLocation: "青岛",
    likeCount: 8,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=14",
    content: "内容很实用，已经收藏，准备慢慢学习。希望作者能继续保持更新，带来更多优质内容。",
    author: "小卫",
    timestamp: DateTime.now().millisecondsSinceEpoch - 13000,
    ipLocation: "大连",
    likeCount: 7,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=15",
    content: "讲得很细致，适合零基础的朋友，非常推荐。希望能有更多相关主题的视频，方便系统学习。",
    author: "小蒋",
    timestamp: DateTime.now().millisecondsSinceEpoch - 14000,
    ipLocation: "合肥",
    likeCount: 6,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=16",
    content: "希望能出一些相关的练习题，方便巩固知识。每次看完都觉得收获满满，非常感谢。",
    author: "小沈",
    timestamp: DateTime.now().millisecondsSinceEpoch - 15000,
    ipLocation: "厦门",
    likeCount: 5,
    dislikeCount: 1,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=17",
    content: "视频内容丰富，讲解方式很有趣，容易吸收。希望能有更多互动内容，提升观看体验。",
    author: "小韩",
    timestamp: DateTime.now().millisecondsSinceEpoch - 16000,
    ipLocation: "济南",
    likeCount: 9,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=18",
    content: "每次都能学到新东西，感谢作者的辛勤付出。希望以后能有更多高质量的内容更新。",
    author: "小杨",
    timestamp: DateTime.now().millisecondsSinceEpoch - 17000,
    ipLocation: "哈尔滨",
    likeCount: 10,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=19",
    content: "建议增加字幕，方便听力不好的朋友观看。内容很新颖，和其他视频不太一样，值得一看。",
    author: "小朱",
    timestamp: DateTime.now().millisecondsSinceEpoch - 18000,
    ipLocation: "长春",
    likeCount: 2,
    dislikeCount: 0,
    topLevel: false,
  ),
  CommentEntity(
    avatarUrl: "https://i.pravatar.cc/150?img=20",
    content: "内容很新颖，和其他视频不太一样，值得一看。希望作者能继续保持创新，带来更多惊喜。",
    author: "小秦",
    timestamp: DateTime.now().millisecondsSinceEpoch - 19000,
    ipLocation: "福州",
    likeCount: 6,
    dislikeCount: 0,
    topLevel: false,
  ),
];

class CommentsSliverList extends StatefulWidget {
  const CommentsSliverList({
    super.key,
    required this.parentComments,
    required this.onTapComment,
    required this.scrollController,
    required this.listKey,
  });

  final GlobalKey listKey;
  final List<CommentEntity> parentComments;
  final ValueSetter<GlobalKey> onTapComment;
  final ScrollController scrollController;

  @override
  State<CommentsSliverList> createState() => _CommentsSliverListState();
}

class _CommentsSliverListState extends State<CommentsSliverList> with TickerProviderStateMixin {
  late final List<ItemDelegate> delegates;
  final Duration duration = Duration(milliseconds: 160);

  void handleInsert(ReplyControlDelegate delegate) async {
    final int delegateIndex = delegates.indexOf(delegate);
    final int addCount = min(delegate.remainingCount, 3);
    final List<CommentEntity> addComments = replyComments.sublist(20 - addCount, 20);
    delegates[delegateIndex] = createReply(
      delegate.parent,
      expanded: true,
      remainingCount: delegate.remainingCount - addCount,
    );

    int addAt = delegateIndex;
    final Duration sizeDuration = duration * (1 / addCount);
    Future<void> future = Future.value();
    for (var value in addComments) {
      final AnimationController opacity = AnimationController(vsync: this, duration: duration);
      opacity.forward();
      final AnimationController sizeFactor =
          AnimationController(vsync: this, duration: sizeDuration);
      future = future.then((value) => sizeFactor.forward());
      delegates.insert(addAt++, createCommon(value, sizeFactor, opacity));
    }
    setState(() {});
  }

  void handleRemove(ReplyControlDelegate delegate) async {
    final int delegateIndex = delegates.indexOf(delegate);
    final int parentIndex = delegates.indexOf(delegate.parent);
    final List<ItemDelegate> collapsedDelegates = [];
    delegates[delegateIndex] = createReply(
      delegate.parent,
      expanded: false,
      collapsedDelegates: collapsedDelegates,
    );
    Future<void> future = Future.value();
    final List<ItemDelegate> removed = delegates.sublist(parentIndex + 1, delegateIndex);
    final Duration duration = this.duration * (1 / removed.length);
    for (var delegate in removed.reversed) {
      (delegate as CommentDelegate).opacity!.reverse();
      final AnimationController controller = delegate.heightFactor!;
      controller.duration = duration;
      future = future.then((_) => controller.reverse());
    }
    future.then((_) {
      collapsedDelegates.addAll(removed);
      delegates.removeWhere((value) => removed.contains(value));
      setState(() {});
    });
  }

  CommentDelegate createCommon(CommentEntity entity,
      [AnimationController? heightFactor, AnimationController? opacity]) {
    final GlobalKey key = GlobalKey();
    return CommentDelegate(
      key: key,
      entity: entity,
      onTap: () => widget.onTapComment(key),
      onLongPress: () {},
      opacity: opacity,
      heightFactor: heightFactor,
    );
  }

  ReplyControlDelegate createReply(
    CommentDelegate commentDelegate, {
    bool expanded = false,
    List<ItemDelegate> collapsedDelegates = const [],
    int? remainingCount,
  }) {
    late final ReplyControlDelegate delegate;

    delegate = ReplyControlDelegate(
      parent: commentDelegate,
      expanded: expanded,
      remainingCount: remainingCount ?? commentDelegate.entity.replyCount,
      onExpand: () => handleInsert(delegate),
      onCollapse: () => handleRemove(delegate),
      collapsedReplies: collapsedDelegates,
    );

    return delegate;
  }

  @override
  void initState() {
    delegates = [];
    for (var entity in widget.parentComments) {
      final CommentDelegate comment = createCommon(entity);
      delegates.add(comment);
      if (entity.replyCount > 0) {
        final ReplyControlDelegate reply = createReply(comment);
        delegates.add(reply);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      key: widget.listKey,
      padding: EdgeInsets.zero,
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          AnimationController animationController = AnimationController(vsync: this);
          animationController.value = 1.0;
          return delegates[index].build(context);
        },
        childCount: delegates.length,
      ),
    );
  }
}

abstract interface class ItemDelegate {
  Widget build(BuildContext context);
}

class CommentDelegate extends ItemDelegate {
  CommentDelegate({
    required this.key,
    required this.entity,
    required this.onTap,
    required this.onLongPress,
    this.heightFactor,
    this.opacity,
  });

  final CommentEntity entity;
  final Key key;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final AnimationController? heightFactor;
  final AnimationController? opacity;

  @override
  Widget build(BuildContext context) {
    return Comment(
      key: key,
      entity: entity,
      onTap: onTap,
      onLongPress: onLongPress,
      heightFactor: heightFactor,
      opacity: opacity,
    );
  }
}

class ReplyControlDelegate extends ItemDelegate {
  ReplyControlDelegate({
    required this.parent,
    required this.expanded,
    required this.remainingCount,
    required this.onExpand,
    required this.onCollapse,
    required this.collapsedReplies,
  });

  final CommentDelegate parent;
  final List<ItemDelegate> collapsedReplies;
  final bool expanded;
  final int remainingCount;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return ReplyControl(
      expanded: expanded,
      onExpand: onExpand,
      onCollapse: onCollapse,
      remainingCount: remainingCount,
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onLongPress,
    this.heightFactor,
    this.opacity,
  });

  final CommentEntity entity;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? heightFactor;
  final Animation<double>? opacity;

  @override
  Widget build(BuildContext context) {
    Widget child = ListTile(
      focusColor: Colors.amber,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: EdgeInsets.fromLTRB(entity.topLevel ? 16 : 60, 0, 16, 0),
      horizontalTitleGap: entity.topLevel ? 8.0 : 4.0,
      titleTextStyle: TextTheme.of(context).labelMedium,
      minTileHeight: 36,
      isThreeLine: true,
      leading: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Image.network(
          entity.avatarUrl,
          height: entity.topLevel ? 36 : 20,
          width: entity.topLevel ? 36 : 20,
          errorBuilder: (context, error, stackTrace) {
            return Container(height: 36, width: 36, color: Colors.grey);
          },
        ),
      ),
      title: Text(entity.author, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(entity.content, style: TextTheme.of(context).bodyMedium),
          SizedBox(height: 4),
          Row(children: [
            Text(
              "${entity.timestamp.formatTimestamp}·${entity.ipLocation}",
              style: TextTheme.of(context).labelMedium,
            ),
            Spacer(),
            Icon(CupertinoIcons.heart, size: 18)
          ])
        ],
      ),
    );
    if (heightFactor != null) {
      child = SizeTransition(sizeFactor: heightFactor!, axisAlignment: -1.0, child: child);
    }

    if (opacity != null) {
      return AnimatedBuilder(
        animation: opacity!,
        builder: (context, c) => Opacity(opacity: opacity!.value, child: child),
      );
    }

    return child;
  }
}

class ReplyControl extends StatelessWidget {
  const ReplyControl({
    super.key,
    required this.expanded,
    required this.onExpand,
    required this.onCollapse,
    required this.remainingCount,
  });

  final bool expanded;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Colors.black.withAlpha(150)),
          textStyle: WidgetStatePropertyAll(TextTheme.of(context).labelLarge),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)),
          minimumSize: WidgetStatePropertyAll(Size(0.0, 0.0)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 60),
          SizedBox(width: 20, child: Divider(thickness: 0.0)),
          if (remainingCount > 0)
            TextButton(
              onPressed: onExpand,
              child: Row(
                children: [
                  Text("展开$remainingCount条回复"),
                  Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          if (remainingCount > 0) SizedBox(width: 8),
          if (expanded)
            TextButton(
              onPressed: onCollapse,
              child: Row(children: [Text("收起"), Icon(Icons.keyboard_arrow_up_rounded)]),
            ),
        ],
      ),
    );
  }
}
