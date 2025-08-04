import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "../../data/tasks_repository.dart";
import "../../domain/task_data.dart";
import "../../l10n/app_localizations.dart";
import "tasks_view_model.dart";

class TasksListView extends StatelessWidget {
  const TasksListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TasksViewModel>(context, listen: false);
    return Consumer<TasksViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              vm.startEditing();
              vm.setStackIndex(1);
            },
          ),
          body: ListView.builder(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            itemCount: vm.tasks.length,
            itemBuilder: (context, index) {
              final task = vm.tasks[index];
              String sDueDate = '';
              if (task.dueDate != null && task.dueDate!.isNotEmpty) {
                final parts = task.dueDate!.split(",");
                final dueDate = DateTime(int.parse(parts[0]),
                    int.parse(parts[1]), int.parse(parts[2]));
                sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
              }
              return Slidable(
                key: ValueKey(task.id),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _delete(context, task, vm),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  color: Colors.grey.shade300,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == "true",
                      onChanged: (v) async =>
                          vm.toggleCompleted(task, v ?? false),
                    ),
                    title: Text(
                      task.description,
                      style: task.completed == "true"
                          ? TextStyle(
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      )
                          : TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.color,
                      ),
                    ),
                    subtitle: task.dueDate == null
                        ? null
                        : Text(
                      sDueDate,
                      style: task.completed == "true"
                          ? TextStyle(
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      )
                          : TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.color,
                      ),
                    ),
                    onTap: () async {
                      if (task.completed == "true") return;
                      vm.startEditing(
                          task: await TasksRepository.db.get(task.id!));
                      vm.setChosenDate(sDueDate);
                      vm.setStackIndex(1);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, TaskData task, TasksViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    await vm.delete(task.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text(l10n.delete_msg('Task')),
      ),
    );
  }
}
