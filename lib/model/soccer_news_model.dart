class SoccerNewsModel {
  final String oid,
      aid,
      officeName,
      title,
      subContent,
      thumbnail,
      datetime,
      sectionName;
  final List<dynamic> words;

  SoccerNewsModel.fromJson(Map<String, dynamic> json)
      : oid = json["oid"],
        aid = json["aid"],
        officeName = json["officeName"],
        title = json["title"],
        subContent = json["subContent"],
        thumbnail = json["thumbnail"],
        datetime = json["datetime"],
        sectionName = json["sectionName"],
        words = json["words"];
}
