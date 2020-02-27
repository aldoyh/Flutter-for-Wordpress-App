import 'package:intl/intl.dart';

class Portfolio {
  final int id;
  final String title;
  final String content;
  final String image;
  final String video;
  final String author;
  final String avatar;
  final String category;
  final String date;
  final String link;
  final int catId;

  Portfolio(
      {this.id,
      this.title,
      this.content,
      this.image,
      this.video,
      this.author,
      this.avatar,
      this.category,
      this.date,
      this.link,
      this.catId});

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    String content = json['content'] != null ? json['content']['rendered'] : "";

    String image = json['_embedded']["wp:featuredmedia"][0]["media_details"]["sizes"]["large"]["source_url"] != ""
        ? json['_embedded']["wp:featuredmedia"][0]["media_details"]["sizes"]["large"]["source_url"]
        : "https://images.wallpaperscraft.com/image/surface_dark_background_texture_50754_1920x1080.jpg";

    String video = json['custom']["td_video"];

    String author = json['custom']["author"]["name"];

    String avatar = json['custom']["author"]["avatar"];

    String category = json["custom"]["categories"] != ""
        ? json["custom"]["categories"][0]["name"]
        : "";

    int catId = json["custom"]["categories"] != ""
        ? json["custom"]["categories"][0]["cat_ID"]
        : 0;

    String date = DateFormat('dd MMMM, yyyy', 'en_US')
        .format(DateTime.parse(json["date"]))
        .toString();

    return Portfolio(
        id: json['id'],
        title: json['title']['rendered'],
        content: content,
        image: image,
        video: video,
        author: author,
        avatar: avatar,
        category: category,
        date: date,
        link: json["link"],
        catId: catId);
  }

  factory Portfolio.fromDatabaseJson(Map<String, dynamic> data) => Portfolio(
      id: data['id'],
      title: data['title'],
      content: data['content'],
      image: data['image'],
      video: data['video'],
      author: data['author'],
      avatar: data['avatar'],
      category: data['category'],
      date: data['date'],
      link: data['link'],
      catId: data["catId"]);

  Map<String, dynamic> toDatabaseJson() => {
        'id': this.id,
        'title': this.title,
        'content': this.content,
        'image': this.image,
        'video': this.video,
        'author': this.author,
        'avatar': this.avatar,
        'category': this.category,
        'date': this.date,
        'link': this.link,
        'catId': this.catId
      };
}
