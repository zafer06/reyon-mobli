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
        title: const Text("Reyon İş Takip"),
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
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3.0),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0.001, 0.009],
                    colors: selectBackColor(topicList[index]),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(2.0),
                  ),
                ),

                /*
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 238, 238),
                  borderRadius: BorderRadius.circular(2),
                  border: const Border(
                    left: BorderSide(
                        width: 8,
                        color: Color.fromARGB(255, 182, 182, 182),
                        style: BorderStyle.solid),
                  ),
                ),
                */
                child: ListTile(
                  title: Text(topicList[index].title),
                  subtitle: Text(topicList[index].user),
                  trailing: Column(
                    children: [
                      Text(topicList[index].date),
                      Text(topicList[index].time),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> selectBackColor(Topic topic) {
    //Duration diff = DateTime.now().difference(topic.datetime);

    List<Color> colorList = [];

    if (topic.date == "Bugün") {
      colorList.add(const Color.fromARGB(213, 173, 173, 173));
      colorList.add(const Color.fromARGB(255, 247, 252, 186));
    } else {
      colorList.add(const Color.fromARGB(213, 173, 173, 173));
      colorList.add(const Color.fromARGB(255, 242, 242, 242));
    }

    return colorList;
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
    Uri url = Uri.parse("https://reyonapi.solokod.com/list");

    final res = await http.post(url);

    if (res.statusCode == 200) {
      final decodeBody = utf8.decode(res.bodyBytes);
      final body = json.decode(decodeBody) as Map<String, dynamic>;
      final data = body["data"] as List<dynamic>;

      List<Topic> topicList = [];

      for (var topic in data) {
        Topic t = Topic.fromJson(topic);
        topicList.add(t);
      }

      //await Future.delayed(const Duration(seconds: 5));

      return topicList;
    } else {
      throw Exception("Topic bilgisi yuklenemidi");
    }
  }

  void menuClick(int item) {
    String version = "0.7.1"; //Helper.getVersion();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hakkında"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Reyon İş takip mobil uygulaması R10 iş forumlarının mobil ortamda gosterimi ve istenildiğinde ilgili forum konusuna ulaşılmasını sağlar."),
            const SizedBox(height: 20.0),
            Text(version),
          ],
        ),
      ),
    );
  }
}
