import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
      child: Material(
        type: MaterialType.transparency,
        child: ColoredBox(color: Colors.white, child: Chat()),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  GlobalKey key = GlobalKey();

  final List<String> historyMessages = ["4", "3", "2", "1"];
  final List<String> newMessage = [];

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            center: key,
            controller: controller,
            anchor: 1.0,
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverList.builder(
                itemCount: historyMessages.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(historyMessages[index]),
                  );
                },
              ),
              SliverToBoxAdapter(key: key),
              SliverList.builder(
                itemCount: newMessage.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(newMessage[index]),
                  );
                },
              ),
            ],
          ),
        ),
        TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            hintText: "评论",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFFF5F5F5),
          ),
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
