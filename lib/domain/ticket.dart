class Ticket {
  String id;

  String title;

  String body;

  Ticket(this.id, this.title, this.body);

  @override
  String toString() {
    return "$id:$title:$body";
  }
}
