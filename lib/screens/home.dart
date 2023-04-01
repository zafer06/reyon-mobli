import 'package:flutter/material.dart';
import 'package:reyon/topic.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late Future<List<Topic>> _futureTopicList;
  late Uri link;

  @override
  void initState() {
    super.initState();
    _futureTopicList = fetchTopic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("R10 İş Takip"),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => menuClick(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text("Hakkında")),
            ],
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Topic>>(
          future: _futureTopicList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Topic>? topicList = snapshot.data;
              return buildListView(topicList!);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget buildListView(List<Topic> topicList) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () {
        return fetchTopic();
      },
      child: ListView.builder(
        itemCount: topicList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onDoubleTap: () async {
              link = Uri.parse(topicList[index].link);

              if (await canLaunchUrl(link)) {
                await launchUrl(link);
              } else {
                throw "Could not launch $link";
              }
            },
            child: ListTile(
              title: Text(topicList[index].title),
              subtitle: Text(topicList[index].date),
            ),
          );
        },
      ),
    );
  }

  Widget buildLoadingScreen() {
    return const Center(
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<List<Topic>> fetchTopic() async {
    Uri url = Uri.parse("https://solokod.com/reyon.json");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      List<Topic> topicList = [];

      final decodeBody = utf8.decode(res.bodyBytes);
      List<dynamic> list = jsonDecode(decodeBody);

      for (var topic in list) {
        Topic t = Topic.fromJson(topic);
        topicList.add(t);
      }

      await Future.delayed(const Duration(seconds: 5));

      return topicList;
    } else {
      throw Exception("Topic bilgisi yuklenemidi");
    }
  }

  void menuClick(int item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hakkında"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
                "R10 İş takip mobil uygulaması R10 iş forumlarının mobil ortamda gosterimi ve istenildiğinde ilgili forum konusuna ulaşılmasını sağlar."),
            SizedBox(height: 20.0),
            Text("Version: 0.7.0"),
          ],
        ),
      ),
    );
  }
}
