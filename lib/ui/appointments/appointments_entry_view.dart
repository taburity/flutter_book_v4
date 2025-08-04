import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils.dart' as utils;
import 'appointments_view_model.dart';

class AppointmentsEntryView extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsViewModel>(
      builder: (context, vm, child) {
        if (vm.entityBeingEdited != null) {
          _titleController.text = vm.entityBeingEdited!.title;
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
                  leading: Icon(Icons.subject),
                  title: TextFormField(
                    decoration: InputDecoration(hintText: "Title"),
                    controller: _titleController,
                    onChanged: (v) => vm.entityBeingEdited!.title = v,
                    validator: (v) => v == null || v.isEmpty ? "Please enter a title" : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(hintText: "Description"),
                    controller: _descriptionController,
                    onChanged: (v) => vm.entityBeingEdited!.description = v,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.today),
                  title: Text("Date"),
                  subtitle: Text(vm.chosenDate ?? ""),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () async {
                      String chosenDate = await utils.selectDate(context, vm.entityBeingEdited!.apptDate);
                      vm.entityBeingEdited!.apptDate = chosenDate;
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.alarm),
                  title: Text("Time"),
                  subtitle: Text(vm.apptTime),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _selectTime(context, vm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, AppointmentsViewModel vm) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (vm.entityBeingEdited!.apptTime != null && vm.entityBeingEdited!.apptTime!.isNotEmpty) {
      List timeParts = vm.entityBeingEdited!.apptTime!.split(",");
      initialTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      vm.entityBeingEdited!.apptTime = "${picked.hour},${picked.minute}";
      vm.setApptTime(picked.format(context));
    }
  }

  void _save(BuildContext context, AppointmentsViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    await vm.save();
    _titleController.clear();
    _descriptionController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(l10n.save_msg('Appointment')),
      ),
    );
  }
}
