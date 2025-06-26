import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_view/chat/chat_text_input.dart';
import 'package:ui_kit/theme/theme.dart';
import 'package:ui_kit/slivers/sliver_align.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleTextStyle: TextTheme.of(context).titleMedium,
          titleSpacing: 0.0,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(color: Colors.amber),
                ),
              ),
              SizedBox(width: 8.0),
              const Text('小明小透明'),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(icon: const Icon(CupertinoIcons.video_camera), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_horiz_sharp), onPressed: () {}),
          ],
          shape: Border(bottom: BorderSide(color: Colors.black12, width: 0.0)),
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                reverse: true,
                slivers: [
                  SliverAlign(
                    sliver: SliverList.list(children: [Container(height: 20, color: Colors.amber)]),
                  ),
                ],
              ),
            ),
            MessageEditor(),
          ],
        ),
      ),
    );
  }
}
