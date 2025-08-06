import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils.dart' as utils;
import 'tasks_view_model.dart';

class TasksEntryView extends StatelessWidget {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksViewModel>(
      builder: (context, vm, child) {
        if (vm.entityBeingEdited != null) {
          _descriptionController.text = vm.entityBeingEdited!.description;
        }
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ElevatedButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    vm.setStackIndex(0);
                  },
                ),
                Spacer(),
                ElevatedButton(
                  child: Text("Save"),
                  onPressed: () => _save(context, vm),
                ),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.description),
                  title: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: "Description"),
                    controller: _descriptionController,
                    onChanged: (v) => vm.entityBeingEdited!.description = v,
                    validator: (v) =>
                    v == null || v.isEmpty ? "Please enter a description" : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.today),
                  title: Text("Due Date"),
                  subtitle: Text(vm.chosenDate ?? ""),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () async {
                      String chosenDate = await utils.selectDate(
                          context, vm.entityBeingEdited!.dueDate);
                      vm.entityBeingEdited!.dueDate = chosenDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context, TasksViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    await vm.save();
    _descriptionController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(l10n.task_save_msg),
      ),
    );
  }
}
