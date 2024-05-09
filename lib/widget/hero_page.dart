import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  late bool _isSearch;
  late List<SoccerNewsModel> resultList;
  final int numberOfNewsPerRequest = 10;
  final int _nextPageTrigger = 3;

  @override
  void initState() {
    super.initState();
    _pageNumber = 0;
    _date = '';
    _search = '';
    _isLastPage = false;
    _loading = true;
    _error = false;
    resultList = [];
    _isSearch = false;
    fetchData();
  }

  Future<void> fetchData() async {
    if (_isSearch) {
      setState(() {
        _pageNumber = 0;
        _date = '';
        _isLastPage = false;
        _loading = true;
        _error = false;
        resultList = [];
        _isSearch = false;
      });
    }
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
            expandedHeight: 200.0,
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
              ),
            ),
            backgroundColor: Colors.grey.withOpacity(0.5),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver:
                SliverList(delegate: SliverChildListDelegate([searchBox()])),
          )
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async {
          _isSearch = true;
          await fetchData();
        },
        child: Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: makeList()),
        ),
      ),
    );
  }

  Column searchBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 16.0),
          child: SizedBox(
            height: 36.0,
            width: double.infinity,
            child: CupertinoTextField(
              keyboardType: TextInputType.text,
              placeholder: '기사를 검색해보세요.',
              placeholderStyle: const TextStyle(
                color: Color(0xffC4C6CC),
                fontSize: 14.0,
                fontFamily: 'Brutal',
              ),
              prefix: const Padding(
                padding: EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                child: Icon(
                  Icons.search,
                  color: Color(0xffC4C6CC),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color(0xffF0F1F5),
              ),
              onSubmitted: (value) async {
                _search = value;
                _isSearch = true;
                await fetchData();
              },
            ),
          ),
        ),
      ],
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
                    child: resultList[index].thumbnail.isEmpty
                        ? SizedBox(
                            width: 150.0,
                            height: 150.0,
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png",
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                "https://dovb-img-proxy.vercel.app/soccerProxy?url=${resultList[index].thumbnail}",
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
