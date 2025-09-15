class TaskDetails {
  final String title;
  final String description;
  final String id;
  bool isDone;

  TaskDetails({
    required this.title,
    required this.description,
    this.isDone = false,
    required this.id
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
        title: json["title"],
        description: json["description"],
        isDone: json["isDone"],
        id: json["id"]
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "isDone": isDone,
        "id" : id,
      };
}