import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatToolbox extends StatelessWidget {
  const ChatToolbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
              SizedBox(width: 24),
              Expanded(child: ToolboxItem()),
            ],
          ),
        ],
      ),
    );
  }
}

class ToolboxItem extends StatelessWidget {
  const ToolboxItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Icon(CupertinoIcons.photo, size: 24, color: Colors.blue)),
          ),
        ),
        SizedBox(height: 4),
        Text("相册", style: TextStyle(fontSize: 12, color: Color(0xFFACADB9))),
      ],
    );
  }
}
