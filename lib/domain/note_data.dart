class NoteData {
  int? id;
  String title;
  String content;
  String color;

  NoteData({
    this.id,
    required this.title,
    required this.content,
    required this.color
  });

  @override
  String toString() {
    return "{ id=$id, title=$title, content=$content, color=$color }";
  }

}
