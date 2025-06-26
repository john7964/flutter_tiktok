import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorts_view/search/search_result.dart';
import 'package:shorts_view/shorts_page/shorts_page.dart';
import 'package:ui_kit/media_certificate/navigator_media_certificate.dart';

class SearchPages extends StatefulWidget {
  const SearchPages({super.key});

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  @override
  Widget build(BuildContext context) {
    return ShortsPages(
      appBar: ShortsSearchBar(),
    );
  }
}

class ShortsSearchBar extends StatelessWidget {
  const ShortsSearchBar({super.key});

  void handlePressSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return NavigatorMediaCertificateScope(
            route: ModalRoute.of(context)!,
            child: SearchList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        dividerTheme: DividerThemeData(color: Colors.white54),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white24),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: WidgetStatePropertyAll(Colors.white70),
            minimumSize: WidgetStatePropertyAll(Size(20, 20)),
            overlayColor: WidgetStatePropertyAll(Colors.white12),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white70, size: 24),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.transparent,
          leadingWidth: 36,
        ),
      ),
      child: AppBar(
        title: FilledButton(
          onPressed: () => handlePressSearch(context),
          child: Row(
            children: [
              Center(child: Icon(CupertinoIcons.search, size: 18)),
              SizedBox(width: 4.0),
              Expanded(child: Text("搜你想看的")),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                child: const VerticalDivider(),
              ),
              Center(child: Text("搜索")),
            ],
          ),
        ),
      ),
    );
  }
}
