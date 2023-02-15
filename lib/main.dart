import 'package:flutter/material.dart';
import 'package:soccer_news_app/widget/hero_page.dart';

void main() {
  runApp(const SoccerNewsApp());
}

class SoccerNewsApp extends StatelessWidget {
  const SoccerNewsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HeroListPage(key: key),
      ),
    );
  }
}
