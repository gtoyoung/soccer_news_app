import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/soccer_news_model.dart';

class DetailView extends StatelessWidget {
  final int heroTag;
  final SoccerNewsModel model;
  const DetailView({Key? key, required this.heroTag, required this.model})
      : super(key: key);

  // 링크로 이동
  onButtonTap(String link) async {
    final url = Uri.parse(link);
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Hero ListView Page 2")),
      body: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        )),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      "${model.thumbnail}?type=w647",
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    model.subContent,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  InkWell(
                    child: const Text(
                      "관련 뉴스기사 보기",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTapDown: (details) {
                      onButtonTap(model.link);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
