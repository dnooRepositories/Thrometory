class Sentence {
  final int id;
  final String name;
  final String text;
  final Map location;

  Sentence({
    required this.id,
    required this.name,
    required this.text,
    required this.location
  });

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
        id: json['id'],
        name: json['name'],
        text: json['text'],
        location: json['location']);
  }
}

class Comments {
  final Map comments;
  final String cursor;

  Comments({
    required this.comments,
    required this.cursor,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
        comments: json['comments'],
        cursor: json['cursor']
    );
  }
}