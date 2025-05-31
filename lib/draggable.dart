// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [DraggableScrollableSheet].

void main() => runApp(const DraggableScrollableSheetExampleApp());

class DraggableScrollableSheetExampleApp extends StatelessWidget {
  const DraggableScrollableSheetExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100)),
      home: Scaffold(
        appBar: AppBar(title: const Text('DraggableScrollableSheet Sample')),
        body: const DraggableScrollableSheetExample(),
      ),
    );
  }
}

class DraggableScrollableSheetExample extends StatefulWidget {
  const DraggableScrollableSheetExample({super.key});

  @override
  State<DraggableScrollableSheetExample> createState() => _DraggableScrollableSheetExampleState();
}

class _DraggableScrollableSheetExampleState extends State<DraggableScrollableSheetExample> {
  double _sheetPosition = 0.5;
  final double _dragSensitivity = 600;
  final DraggableScrollableController _scrollController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constrains) {
              return Container(
                color: Colors.amber,
                child: TextButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      1.0,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text("点击"),
                ),
              );
            },
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 600),
          child: DraggableScrollableSheet(
            controller: _scrollController,
            initialChildSize: _sheetPosition,
            minChildSize: 0.5,
            maxChildSize: 1,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return ColoredBox(
                color: colorScheme.primary,
                child: Column(
                  children: <Widget>[
                    Grabber(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        setState(() {
                          _sheetPosition -= details.delta.dy / _dragSensitivity;
                          if (_sheetPosition < 0.25) {
                            _sheetPosition = 0.25;
                          }
                          if (_sheetPosition > 1.0) {
                            _sheetPosition = 1.0;
                          }
                        });
                      },
                      isOnDesktopAndWeb: _isOnDesktopAndWeb,
                    ),
                    Flexible(
                      child: ListView.builder(
                        controller: _isOnDesktopAndWeb ? null : scrollController,
                        itemCount: 25,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              'Item $index',
                              style: TextStyle(color: colorScheme.surface),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
        TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
      };
}

/// A draggable widget that accepts vertical drag gestures
/// and this is only visible on desktop and web platforms.
class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate, required this.isOnDesktopAndWeb});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: colorScheme.onSurface,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
