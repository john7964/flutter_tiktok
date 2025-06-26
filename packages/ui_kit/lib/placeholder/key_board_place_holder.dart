import 'dart:math';

import 'package:flutter/material.dart';

class KeyBoardPlaceholder extends StatelessWidget {
  const KeyBoardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: max(
        MediaQuery.of(context).viewPadding.bottom,
        MediaQuery.of(context).viewInsets.bottom,
      ),
    );
  }
}
