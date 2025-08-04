class TaskData {

  int? id;
  String description;
  String? dueDate;
  String completed;

  TaskData({
    this.id,
    required this.description,
    this.dueDate,
    this.completed = "false"
  });

  @override
  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }

}