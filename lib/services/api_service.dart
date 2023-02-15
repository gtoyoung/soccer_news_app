import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:soccer_news_app/model/soccer_news_model.dart';

class ApiService {
  static const baseUrl = "http://api.dovb.kro.kr/newsList";

  static Future<List<SoccerNewsModel>> getSoccerNewsList(
      String page, String date, String search, String size) async {
    List<SoccerNewsModel> newsInstances = [];

    String targetUrl = baseUrl +
        "?date=$date&page=$page" +
        "&size=${size.isEmpty ? "10" : size}" +
        (search.isNotEmpty ? "&search=$search" : "");

    final url = Uri.parse(targetUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic contents = jsonDecode(response.body);
      final List<dynamic> newsList = contents["content"];
      for (var news in newsList) {
        final trg = SoccerNewsModel.fromJson(news);
        newsInstances.add(trg);
      }

      return newsInstances;
    }
    throw Error();
  }
}
