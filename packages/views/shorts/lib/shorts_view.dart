import 'package:flutter/cupertino.dart';
import 'package:shorts_view/search/search_result.dart';
import 'package:shorts_view/shorts_page/shorts_page.dart';
import 'package:view_integration/shorts_provider.dart';

import 'home_short_page.dart';

class ShortsDelegateImpl extends ShortsDelegate {
  ShortsDelegateImpl._();

  static final ShortsDelegate instance = ShortsDelegateImpl._();
  @override
  final Widget recommendedPages = const ShortsPages();
  @override
  final Widget followedPages = const RecommendedPages();
  @override
  final Widget searchResult = const SearchList();
}
