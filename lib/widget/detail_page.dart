import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: model.thumbnail.isEmpty
                          ? Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png",
                              fit: BoxFit.contain,
                              height: double.infinity,
                              width: double.infinity,
                              alignment: Alignment.center,
                            )
                          : Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://dovb-img-proxy.vercel.app/soccerProxy?url=${model.thumbnail}?type=w647",
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )),
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
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    child: const Text(
                      "관련 뉴스기사 보기",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          backgroundColor: Colors.cyan),
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
