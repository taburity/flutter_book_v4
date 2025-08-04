import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "tasks_list_view.dart";
import "tasks_entry_view.dart";
import "tasks_view_model.dart";
import "../../data/tasks_repository.dart";

class TasksView extends StatelessWidget {
  final Directory _docsDir;

  const TasksView({super.key, required Directory docsDir}) : _docsDir = docsDir;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TasksViewModel>(
      create: (context) {
        TasksRepository.init(_docsDir);
        final vm = TasksViewModel();
        vm.loadTasks();
        return vm;
      },
      child: Consumer<TasksViewModel>(
        builder: (context, vm, child) {
          return IndexedStack(
            index: vm.stackIndex,
            children: [
              TasksListView(),
              TasksEntryView(),
            ],
          );
        },
      ),
    );
  }
}
