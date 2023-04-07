import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:soccer_news_app/model/soccer_news_model.dart';

class ApiService {
  static const baseUrl = "http://api.dovb.kro.kr/newsList";

  static Future<List<SoccerNewsModel>> getSoccerNewsList(
      int page, String date, String search, int size) async {
    List<SoccerNewsModel> newsInstances = [];

    String targetUrl = baseUrl +
        "?page=$page" +
        "&size=${size.isNaN ? "10" : size}" +
        (date.isEmpty ? "" : "&date=$date") +
        (search.isNotEmpty ? "&search=$search" : "");

    final url = Uri.parse(targetUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic contents = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> newsList = contents["content"];
      final int totalPages = contents["totalPages"];
      for (var news in newsList) {
        final trg = SoccerNewsModel.fromJson(news, totalPages);
        newsInstances.add(trg);
      }

      return newsInstances;
    }
    throw Error();
  }
}
