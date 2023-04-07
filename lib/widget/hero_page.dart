import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:soccer_news_app/model/soccer_news_model.dart';
import 'package:soccer_news_app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soccer_news_app/widget/detail_page.dart';

class HeroListPage extends StatefulWidget {
  const HeroListPage({Key? key}) : super(key: key);

  @override
  State<HeroListPage> createState() => _HeroListPageState();
}

class _HeroListPageState extends State<HeroListPage> {
  late bool _isLastPage;
  late int _pageNumber;
  late String _date;
  late String _search;
  late bool _error;
  late bool _loading;
  late List<SoccerNewsModel> resultList;
  final int numberOfNewsPerRequest = 10;
  final int _nextPageTrigger = 3;

  @override
  void initState() {
    super.initState();
    _pageNumber = 1;
    _date = '';
    _search = '';
    _isLastPage = false;
    _loading = true;
    _error = false;
    resultList = [];

    fetchData();
  }

  Future<void> fetchData() async {
    try {
      ApiService.getSoccerNewsList(
              _pageNumber, _date, _search, numberOfNewsPerRequest)
          .then((value) {
        setState(() {
          _isLastPage = value.length < numberOfNewsPerRequest;
          _loading = false;
          _pageNumber = _pageNumber + 1;
          resultList.addAll(value);
        });
      });
    } catch (e) {
      print("error --> $e");
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Widget errorDialog({required double size}) {
    return SizedBox(
      height: 180,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'An error occurred when fetching the posts.',
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = false;
                  fetchData();
                });
              },
              child: const Text(
                "Retry",
                style: TextStyle(fontSize: 20, color: Colors.purpleAccent),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildNewsView(),
    );
  }

  Widget buildNewsView() {
    if (resultList.isEmpty) {
      if (_loading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (_error) {
        return Center(
          child: errorDialog(size: 20),
        );
      }
    }
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            floating: true,
            pinned: false,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.pin,
                title: const Text("해축 News",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Image.network(
                  "https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                  fit: BoxFit.cover,
                )),
            backgroundColor: Colors.grey.withOpacity(0.5),
          ),
        ];
      },
      body: Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: makeList()),
      ),
    );
  }

  ListView makeList() {
    return ListView.builder(
      itemCount: resultList.length + (_isLastPage ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == resultList.length - _nextPageTrigger) {
          fetchData();
        }

        if (index == resultList.length) {
          if (_error) {
            return Center(
              child: errorDialog(size: 15),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            );
          }
        }
        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext build) {
                return DetailView(
                  heroTag: index,
                  model: resultList[index],
                );
              },
            );
          },
          onLongPress: () => {
            showDialog(
                context: context,
                builder: (BuildContext build) {
                  return InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(resultList[index].link),
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                        android: AndroidInAppWebViewOptions(
                            useHybridComposition: true)),
                  );
                })
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Hero(
                  tag: index,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: resultList[index].thumbnail.isEmpty
                          ? "https://cdn-icons-png.flaticon.com/128/9718/9718823.png"
                          : resultList[index].thumbnail,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                  resultList[index].title,
                  style: Theme.of(context).textTheme.titleLarge,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
