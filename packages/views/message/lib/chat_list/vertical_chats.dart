import 'package:flutter/material.dart';
import 'package:message_view/chat/chat_room.dart';
import 'package:ui_kit/route/positioned_popup_route.dart';

import 'chat_list.dart';

class VerticalChats extends StatefulWidget {
  const VerticalChats({super.key});

  @override
  State<VerticalChats> createState() => _VerticalChatsState();
}

class _VerticalChatsState extends State<VerticalChats> {
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return VerticalChatsItem();
      },
      separatorBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(left: 78.0),
          child: Divider(thickness: 0.0, height: 0.0, color: Colors.black12),
        );
      },
    );
  }
}

class VerticalChatsItem extends StatelessWidget {
  const VerticalChatsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        final NavigatorState navigator = Navigator.of(context);
        final renderObject = navigator.context.findRenderObject() as RenderBox;
        final child = context.findRenderObject() as RenderBox;
        final Offset offset = child.localToGlobal(details.localPosition, ancestor: renderObject);
        final Route route = PositionedPopupRoute(
          offset: offset,
          alignment: Alignment.bottomCenter,
          builder: (context) => Popup(),
        );

        Navigator.of(context).push(route);
      },
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ChatRoom();
              },
            ),
          );
        },
        horizontalTitleGap: 8.0,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(28.0),
          child: Container(width: 56.0, height: 56.0, color: Colors.deepPurple),
        ),
        title: Row(
          children: [
            Expanded(child: Text("猫猫交流群", maxLines: 1, overflow: TextOverflow.ellipsis)),
            SizedBox(width: 12.0),
            Text("06:48", style: TextTheme.of(context).labelMedium),
          ],
        ),
        titleTextStyle: TextTheme.of(context).titleMedium,
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                "没有新通知没有新通知没有新通知没有新通知没有新通知没有新通知",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12.0),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
