import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/pages/single_Article.dart';
import 'package:flutter_wordpress_app/widgets/articleBox.dart';
import 'package:flutter_wordpress_app/widgets/articleBoxFeatured.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';
import 'package:flutter_wordpress_app/models/Portfolio.dart';

class Portfolios extends StatefulWidget {
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolios> {
  List<dynamic> featuredPorts = [];
  List<dynamic> latestArticles = [];
  Future<List<dynamic>> _futureLatestPorts;
  Future<List<dynamic>> _futureFeaturedPorts;
  ScrollController _controller;
  int page = 1;
  bool _infiniteStop;

  @override
  void initState() {
    super.initState();
    _futureLatestPorts = fetchLatestPorts(1);
    _futureFeaturedPorts = fetchFeaturedPorts(1);
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollListener);
    _infiniteStop = false;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<List<dynamic>> fetchLatestPorts(int page) async {
    try {
      var response = await http.get(
          'https://doy.tech/wp-json/wp/v2/jetpack-portfolio/?_embed&page=$page&per_page=10');
      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            latestArticles.addAll(json
                .decode(response.body)
                .map((m) => Portfolio.fromJson(m))
                .toList());
            print(latestArticles);
            if (latestArticles.length % 10 != 0) {
              _infiniteStop = true;
            }
          });
          return latestArticles;
        }
        setState(() {
          _infiniteStop = true;
        });
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return latestArticles;
  }

  Future<List<dynamic>> fetchFeaturedPorts(int page) async {
    try {
      var response = await http.get(
          "$WORDPRESS_URL/wp-json/wp/v2/jetpack-portfolio/?_embed&page=$page&per_page=10");
          // "$WORDPRESS_URL/wp-json/wp/v2/portfolio/?jetpack-portfolio-type[]=$FEATURED_ID&page=$page&per_page=10");

      if (this.mounted) {
        if (response.statusCode == 200) {
          setState(() {
            featuredPorts.addAll(json
                .decode(response.body)
                .map((m) => Portfolio.fromJson(m))
                .toList());
          });

          return featuredPorts;
        } else {
          setState(() {
            _infiniteStop = true;
          });
        }
      }
    } on SocketException {
      throw 'No Internet connection';
    }
    return featuredPorts;
  }

  _scrollListener() {
    var isEnd = _controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange;
    if (isEnd) {
      setState(() {
        page += 1;
        _futureLatestPorts = fetchLatestPorts(page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white12,
        appBar: AppBar(
          title: Image(
            image: AssetImage('assets/doytech-4dark.png'),
            height: 45,
          ),
          elevation: 5,
          backgroundColor: Colors.white12,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white70),
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                featuredPost(_futureFeaturedPorts),
                latestPosts(_futureLatestPorts)
              ],
            ),
          ),
        ));
  }

  Widget latestPosts(Future<List<dynamic>> latestPorts) {
    return FutureBuilder<List<dynamic>>(
      future: latestPorts,
      builder: (context, articleSnapshot) {
        if (articleSnapshot.hasData) {
          if (articleSnapshot.data.length == 0) return Container();
          return Column(
            children: <Widget>[
              Column(
                  children: articleSnapshot.data.map((item) {
                final heroId = item.id.toString() + "-latest";
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleArticle(item, heroId),
                      ),
                    );
                  },
                  child: articleBox(context, item, heroId),
                );
              }).toList()),
              !_infiniteStop
                  ? Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: Loading(
                          indicator: BallBeatIndicator(),
                          size: 60.0,
                          color: Theme.of(context).accentColor))
                  : Container()
            ],
          );
        } else if (articleSnapshot.hasError) {
          return Container();
        }
        return Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: Loading(
                indicator: BallBeatIndicator(),
                size: 60.0,
                color: Theme.of(context).accentColor));
      },
    );
  }

  Widget featuredPost(Future<List<dynamic>> featuredPorts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: FutureBuilder<List<dynamic>>(
        future: featuredPorts,
        builder: (context, articleSnapshot) {
          if (articleSnapshot.hasData) {
            if (articleSnapshot.data.length == 0) return Container();
            return Row(
                children: articleSnapshot.data.map((item) {
              final heroId = item.id.toString() + "-featured";
              return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleArticle(item, heroId),
                      ),
                    );
                  },
                  child: articleBoxFeatured(context, item, heroId));
            }).toList());
          } else if (articleSnapshot.hasError) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/no-internet.png",
                    width: 250,
                  ),
                  Text("No Internet Connection."),
                  FlatButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text("Reload"),
                    onPressed: () {
                      _futureLatestPorts = fetchLatestPorts(1);
                      _futureFeaturedPorts = fetchFeaturedPorts(1);
                    },
                  )
                ],
              ),
            );
          }
          return Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 280,
              child: Loading(
                  indicator: BallBeatIndicator(),
                  size: 60.0,
                  color: Theme.of(context).accentColor));
        },
      ),
    );
  }
}
