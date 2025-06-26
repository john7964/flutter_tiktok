import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/custom_layout.dart';
import 'package:ui_kit/placeholder/key_board_place_holder.dart';

class MessageEditor extends StatefulWidget {
  const MessageEditor({super.key});

  @override
  State<MessageEditor> createState() => _MessageEditorState();
}

class _MessageEditorState extends State<MessageEditor> with TickerProviderStateMixin {
  final FocusNode inputFocusNode = FocusNode();
  final FocusNode toolBoxFocusNode = FocusNode();
  final TextEditingController inputController = TextEditingController();

  void toggleToolBox() {
    if (toolBoxFocusNode.hasFocus) {
      toolBoxFocusNode.unfocus();
    } else {
      toolBoxFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget inputSuffix = GestureDetector(
      onTap: toggleToolBox,
      child: ListenableBuilder(
        listenable: toolBoxFocusNode,
        builder: (context, child) {
          return AnimatedRotation(
            turns: toolBoxFocusNode.hasFocus ? -1 / 8 : 0.0,
            duration: Duration(milliseconds: 150),
            child: child!,
          );
        },
        child: Icon(CupertinoIcons.add_circled, size: 33),
      ),
    );

    final Widget input = ChatTextInput(
      focusNode: inputFocusNode,
      controller: inputController,
      suffix: inputSuffix,
    );

    final Widget toolBox = ChatToolbox(focusNode: toolBoxFocusNode);

    return ChatInputWrapper(
      inputFocusNode: inputFocusNode,
      toolBoxFocusNode: toolBoxFocusNode,
      input: input,
      toolBox: toolBox,
    );
  }
}

class ChatInputWrapper extends StatefulWidget {
  const ChatInputWrapper({
    super.key,
    required this.input,
    required this.toolBox,
    required this.inputFocusNode,
    required this.toolBoxFocusNode,
  });

  final FocusNode inputFocusNode;
  final FocusNode toolBoxFocusNode;
  final Widget input;
  final Widget toolBox;

  @override
  State<ChatInputWrapper> createState() => _ChatInputWrapperState();
}

class _ChatInputWrapperState extends State<ChatInputWrapper> with TickerProviderStateMixin {
  final FocusScopeNode focusScopeNode = FocusScopeNode();
  final GlobalKey stackKey = GlobalKey();
  Size initialSize = Size.zero;
  late final AnimationController toolBoxController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  void handleShowToolBoxChanged() {
    if (widget.toolBoxFocusNode.hasFocus) {
      initialSize = stackKey.currentContext!.size!;
      toolBoxController.forward();
    } else {
      toolBoxController.reverse();
    }
  }

  @override
  void initState() {
    widget.toolBoxFocusNode.addListener(handleShowToolBoxChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatInputWrapper oldWidget) {
    if (oldWidget.toolBoxFocusNode != widget.toolBoxFocusNode) {
      oldWidget.toolBoxFocusNode.removeListener(handleShowToolBoxChanged);
      widget.toolBoxFocusNode.addListener(handleShowToolBoxChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: focusScopeNode,
      child: TapRegion(
        onTapOutside: (event) {
          focusScopeNode.unfocus();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: widget.input,
            ),
            Stack(
              key: stackKey,
              alignment: Alignment.bottomCenter,
              children: [
                AnimatedBuilder(
                  animation: toolBoxController,
                  builder: (context, child) {
                    return SizedBoxBuilder.forSize(
                      alignment: Alignment.topCenter,
                      sizeBuilder: (constrains, childSize) {
                        if (toolBoxController.isForwardOrCompleted) {
                          final double difference = childSize.height - initialSize.height;
                          final double height =
                              initialSize.height + (difference * toolBoxController.value);
                          return Size(constrains.maxWidth, height);
                        } else {
                          return Size(
                            constrains.maxWidth,
                            childSize.height * toolBoxController.value,
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
                        child: widget.toolBox,
                      ),
                    );
                  },
                ),
                KeyBoardPlaceholder(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    focusScopeNode.dispose();
    widget.toolBoxFocusNode.removeListener(handleShowToolBoxChanged);
    super.dispose();
  }
}

class ChatTextInput extends StatelessWidget {
  const ChatTextInput({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.suffix,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(fontSize: 16, height: 1.2),
      onEditingComplete: () {},
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      textInputAction: TextInputAction.send,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: "发送消息",
        hintStyle: TextStyle(color: Color(0xFFACADB9), height: 1.2, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color(0xFFEEEEEE),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(25)),
            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
          ),
        ),
        suffixIcon: suffix,
        suffixIconConstraints: BoxConstraints(
          maxHeight: 33,
          minHeight: 33,
          maxWidth: 43,
          minWidth: 43,
        ),
        prefixIconConstraints: BoxConstraints(
          maxHeight: 33,
          minHeight: 33,
          maxWidth: 43,
          minWidth: 43,
        ),
      ),
    );
  }
}

class ChatToolbox extends StatelessWidget {
  const ChatToolbox({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Padding(
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
