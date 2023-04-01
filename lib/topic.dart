class Topic {
  final String title;
  final String link;
  final String user;
  final String date;
  final String reply;
  final String description;

  const Topic({
    required this.title,
    required this.link,
    required this.user,
    required this.date,
    required this.reply,
    required this.description,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json["title"],
      link: json["link"],
      user: json["user"],
      date: json["date"],
      reply: json["reply"],
      description: json["description"],
    );
  }
}
