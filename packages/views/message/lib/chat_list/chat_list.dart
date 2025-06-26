import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:message_view/chat_list/horizontal_chats.dart';
import 'package:message_view/chat_list/vertical_chats.dart';
import 'package:ui_kit/route/drawer_route.dart';
import 'package:ui_kit/theme/theme.dart';
import 'package:view_integration/message_provider.dart';
import 'package:ui_kit/route/positioned_popup_route.dart';

class MessageDelegateImpl extends MessageDelegate {
  @override
  Widget messageMain() => const MessageView();
}

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
      child: Material(color: Colors.white, child: Chat()),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 24),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          titleTextStyle: TextTheme.of(context).titleMedium!,
          backgroundColor: Colors.white,
          leading: IconButton(
            style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () {
              Navigator.of(
                context,
              ).push(SlideDrawer(builder: (context) => Container(color: Colors.amber)));
            },
            icon: Icon(Icons.format_align_left),
          ),
          actionsPadding: EdgeInsets.only(right: 12.0),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
            SizedBox(width: 8.0),
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    final NavigatorState navigator = Navigator.of(context);
                    final renderObject = navigator.context.findRenderObject() as RenderBox;
                    final child = context.findRenderObject() as RenderBox;
                    final Offset offset = child.localToGlobal(
                      child.size.bottomRight(Offset.zero),
                      ancestor: renderObject,
                    );
                    final Route route = PositionedPopupRoute(
                      offset: offset,
                      alignment: Alignment.topRight,
                      builder: (context) => Popup(),
                    );

                    Navigator.of(context).push(route);
                  },
                  icon: Icon(Icons.add_circle_outline),
                );
              },
            ),
          ],
          title: Text("消息"),
        ),
        body: CustomScrollView(
          controller: controller,
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: HorizontalChats(),
              ),
            ),
            VerticalChats(),
          ],
        ),
      ),
    );
  }
}

class Popup extends StatefulWidget {
  const Popup({super.key});

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0.0, 6.0), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: DefaultTextStyle(
          style: TextTheme.of(context).titleSmall!,
          child: UnconstrainedBox(
            constrainedAxis: Axis.horizontal,
            child: CupertinoListSection.insetGrouped(
              backgroundColor: Colors.transparent,
              margin: EdgeInsetsGeometry.zero,
              additionalDividerMargin: 0.0,
              hasLeading: false,
              topMargin: 0.0,
              dividerMargin: 0.0,
              children: [
                CupertinoListTile(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
                  leadingToTitle: 8.0,
                  onTap: () {},
                  leadingSize: 24,
                  leading: Icon(Icons.chat_bubble_outline, size: 22),
                  title: Text("发起群聊", style: TextTheme.of(context).titleSmall!),
                ),
                CupertinoListTile(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
                  leadingToTitle: 8.0,
                  onTap: () {},
                  leadingSize: 24,
                  leading: Icon(Icons.person_add_alt_1_outlined, size: 22),
                  title: Text("添加朋友", style: TextTheme.of(context).titleSmall!),
                ),
                CupertinoListTile(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
                  leadingToTitle: 8.0,
                  onTap: () {},
                  leadingSize: 24,
                  leading: Icon(CupertinoIcons.qrcode_viewfinder, size: 22),
                  title: Text("扫一扫", style: TextTheme.of(context).titleSmall!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
