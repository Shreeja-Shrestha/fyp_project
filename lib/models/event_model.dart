class Event {
  final String title;
  final String date;
  final String description;

  Event({required this.title, required this.date, required this.description});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: json['date'],
      description: json['description'] ?? '',
    );
  }
}
