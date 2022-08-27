class Note {
  int? id;
  String? title;
  DateTime? date;
  String? priorty;
  int? status;

  Note({this.title, this.date, this.priorty, this.status});

  Note.withId({this.id, this.title, this.date, this.priorty, this.status});

  Map<String, dynamic> toMap() {
    // ignore: prefer_collection_literals
    final map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date!.toIso8601String();
    map['priorty'] = priorty;
    map['status'] = status;

    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        priorty: map['priorty'],
        status: map['status']);
  }
}
