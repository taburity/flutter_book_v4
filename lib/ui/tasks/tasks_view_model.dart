import 'package:flutter/material.dart';
import '../../domain/task_data.dart';
import '../../data/tasks_repository.dart';

class TasksViewModel extends ChangeNotifier {
  int _stackIndex = 0;
  int get stackIndex => _stackIndex;
  List<TaskData> _tasks = [];
  List<TaskData> get tasks => _tasks;
  TaskData? entityBeingEdited;
  String? chosenDate;

  Future<void> loadTasks() async {
    _tasks = await TasksRepository.db.getAll();
    notifyListeners();
  }

  void startEditing({TaskData? task}) {
    entityBeingEdited = task ?? TaskData(description: '', completed: 'false');
    notifyListeners();
  }

  void setChosenDate(String? date) {
    chosenDate = date;
    notifyListeners();
  }

  void setStackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  Future<void> save() async {
    if (entityBeingEdited == null) return;
    if (entityBeingEdited!.id == null) {
      await TasksRepository.db.create(entityBeingEdited!);
    } else {
      await TasksRepository.db.update(entityBeingEdited!);
    }
    await loadTasks();
    setStackIndex(0);
  }

  Future<void> delete(int id) async {
    await TasksRepository.db.delete(id);
    await loadTasks();
  }

  Future<void> toggleCompleted(TaskData task, bool value) async {
    task.completed = value.toString();
    await TasksRepository.db.update(task);
    await loadTasks();
  }
}
