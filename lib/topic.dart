class Topic {
  final String title;
  final String link;
  final String user;
  final String date;
  final String time;
  final String reply;
  final String description;

  const Topic({
    required this.title,
    required this.link,
    required this.user,
    required this.date,
    required this.time,
    required this.reply,
    required this.description,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final datetime = json["date"].split(" ");

    return Topic(
      title: json["title"],
      link: json["link"],
      user: json["user"],
      date: formatDate(datetime[0]),
      time: datetime[1],
      reply: json["reply"],
      description: json["description"],
    );
  }

  static String formatDate(String date) {
    DateTime today = DateTime.now();
    DateTime dateTime = DateTime.parse(date);
    final numbers = date.split("-");

    Duration difference = today.difference(dateTime);
    if (difference.inDays == 0) {
      return "Bugün";
    } else if (difference.inDays == 1) {
      return "Dün";
    } else {
      return "${numbers[2]}.${numbers[1]}.${numbers[0]}";
    }
  }
}
