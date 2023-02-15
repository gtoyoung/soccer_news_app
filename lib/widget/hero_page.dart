import 'package:flutter/material.dart';
import 'package:soccer_news_app/model/soccer_news_model.dart';
import 'package:soccer_news_app/services/api_service.dart';

class HeroListPage extends StatefulWidget {
  const HeroListPage({Key? key}) : super(key: key);

  @override
  State<HeroListPage> createState() => _HeroListPageState();
}

class _HeroListPageState extends State<HeroListPage> {
  late Future<List<SoccerNewsModel>> newsList;

  @override
  void initState() {
    super.initState();
    newsList = ApiService.getSoccerNewsList("1", "20230215", "", "10");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: const Text("해축 News",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    "https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FutureBuilder(
              future: newsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return makeList(
                      snapshot as AsyncSnapshot<List<SoccerNewsModel>>);
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<SoccerNewsModel>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SecondPage(
                      heroTag: index,
                      model: snapshot.data![index],
                    )));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Hero(
                  tag: index,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      snapshot.data![index].thumbnail,
                      width: 200,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                  snapshot.data![index].title,
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

class SecondPage extends StatelessWidget {
  final int heroTag;
  final SoccerNewsModel model;
  const SecondPage({Key? key, required this.heroTag, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hero ListView Page 2")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
            child: Text(
              model.subContent,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        ],
      ),
    );
  }
}

final List<String> _images = [
  'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  'https://images.pexels.com/photos/2662116/pexels-photo-2662116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/273935/pexels-photo-273935.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/1591373/pexels-photo-1591373.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/462024/pexels-photo-462024.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  'https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
];
