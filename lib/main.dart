import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    // overlays: [SystemUiOverlay.top],
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}

class TestNavigator extends StatefulWidget {
  const TestNavigator({super.key});

  @override
  State<TestNavigator> createState() => _TestNavigatorState();
}

class _TestNavigatorState extends State<TestNavigator> with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> key = GlobalKey();
  late final TabController controller = TabController(length: 2, vsync: this);
  late final TabController controller2 = TabController(length: 2, vsync: this);
  double value = 0;

  late final Map<Type, GestureRecognizerFactory> gestures = {
    HorizontalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(debugOwner: this),
          (HorizontalDragGestureRecognizer instance) {
            instance.onlyAcceptDragOnThreshold = false
            // ..onUpdate =  (details) => print(details)
            // ..onEnd = (details) => print(details)
            ;
          },
        ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TabBarView(
        controller: controller,
        children: [
          Container(
            color: Colors.green,
            child: Center(
              child: Container(
                color: Colors.red,
                height: 100,
                child: Material(
                  type: MaterialType.transparency,
                  child: GestureDetector(
                    // gestures: gestures,
                    // onHorizontalDragStart: (details) {
                    //   print(details);
                    // },
                  ),
                ),
              ),
            ),
          ),
          Container(color: Colors.yellow),
        ],
      ),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBar(title: Text("asd")));

    return Scaffold(
      appBar: AppBar(title: Text("asd")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Test()));
              },
              child: Text("点击2"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("返回"),
            ),
          ],
        ),
      ),
    );
  }
}
