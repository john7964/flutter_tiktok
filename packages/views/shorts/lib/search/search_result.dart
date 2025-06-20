import 'package:flutter/material.dart';
import 'package:shorts_view/shorts_list/shorts_list.dart';
import 'package:ui_kit/media_certificate/indexed_media_certificate.dart';
import 'package:ui_kit/theme.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> with SingleTickerProviderStateMixin {
  final ValueNotifier<int> currentTab = ValueNotifier(0);
  late final TabController tabController;

  void handleTabChanged() {
    currentTab.value = tabController.index;
  }

  @override
  void initState() {
    tabController = TabController(length: 6, vsync: this);
    tabController.addListener(handleTabChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => FocusScope.of(context).unfocus(),
      child: Theme(
        data: lightTheme,
        child: Material(
          color: Color(0xFFF8F8F8),
          child: NestedScrollView(
            headerSliverBuilder: (context, scrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: PinnedHeaderSliver(
                    child: SearchAppBar(bodyScrolled: scrolled, controller: tabController),
                  ),
                ),
              ];
            },
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: IndexedMediaCertificateDispatcher(
                controller: currentTab,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    IndexedMediaCertificateScope(index: 0, child: ShortsList()),
                    IndexedMediaCertificateScope(index: 1, child: SizedBox()),
                    IndexedMediaCertificateScope(index: 2, child: SizedBox()),
                    IndexedMediaCertificateScope(index: 3, child: SizedBox()),
                    IndexedMediaCertificateScope(index: 4, child: SizedBox()),
                    IndexedMediaCertificateScope(index: 5, child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    currentTab.dispose();
    super.dispose();
  }
}

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key, this.bodyScrolled = false, required this.controller});

  final bool bodyScrolled;
  final TabController controller;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.black87),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStatePropertyAll(Size(20, 20)),
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            iconSize: WidgetStatePropertyAll(22.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.black87),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStatePropertyAll(Size(20, 20)),
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            textStyle: WidgetStatePropertyAll(TextTheme.of(context).titleSmall),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          tabAlignment: TabAlignment.start,
          dividerHeight: 0.0,
          labelStyle: TextTheme.of(context).titleSmall!.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextTheme.of(context).titleSmall!.copyWith(color: Colors.black54),
          labelPadding: EdgeInsets.symmetric(horizontal: 14),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          indicatorColor: Colors.black87,
        ),
        inputDecorationTheme: InputDecorationTheme(
          constraints: BoxConstraints(maxHeight: 38),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          hintStyle: TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color(0xFFE7E7E9),
        ),
      ),
      child: Container(
        color: widget.bodyScrolled ? Colors.white : null,
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios_new)),
                Expanded(child: TextField(decoration: InputDecoration(hintText: "评论"))),
                TextButton(onPressed: () {}, child: Text("搜索"))
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    padding: EdgeInsets.zero,
                    controller: widget.controller,
                    tabs: [
                      Tab(text: "综合", height: 36),
                      Tab(text: "视频", height: 36),
                      Tab(text: "用户", height: 36),
                      Tab(text: "商品", height: 36),
                      Tab(text: "直播", height: 36),
                      Tab(text: "音乐", height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
