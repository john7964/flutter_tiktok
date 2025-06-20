import 'package:flutter/widgets.dart';

class RootNavigator extends Navigator {
  const RootNavigator({
    super.key,
    super.pages = const <Page<dynamic>>[],
    super.initialRoute,
    super.onGenerateInitialRoutes = Navigator.defaultGenerateInitialRoutes,
    super.onGenerateRoute,
    super.onUnknownRoute,
    super.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    super.reportsRouteUpdateToEngine = false,
    super.clipBehavior = Clip.hardEdge,
    super.observers = const <NavigatorObserver>[],
    super.requestFocus = true,
    super.restorationScopeId,
    super.routeTraversalEdgeBehavior = kDefaultRouteTraversalEdgeBehavior,
    super.onDidRemovePage,
  });

  static RootNavigatorState of(BuildContext context) {
    RootNavigatorState? navigator;
    if (context case StatefulElement(:final RootNavigatorState state)) {
      navigator = state;
    }

    navigator = navigator ?? context.findAncestorStateOfType<RootNavigatorState>();

    assert(() {
      if (navigator == null) {
        throw FlutterError(
          'Navigator operation requested with a context that does not include a Navigator.\n'
          'The context used to push or pop routes from the Navigator must be that of a '
          'widget that is a descendant of a Navigator widget.',
        );
      }
      return true;
    }());
    return navigator!;
  }

  @override
  RootNavigatorState createState() => RootNavigatorState();
}

class RootNavigatorState extends NavigatorState {
}
