import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../l10n/app_localizations.dart";
import "notes_view_model.dart";

class NotesEntryView extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesViewModel>(
      builder: (context, vm, child) {
        if (vm.entityBeingEdited != null) {
          _titleController.text = vm.entityBeingEdited!.title;
          _contentController.text = vm.entityBeingEdited!.content;
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
                  leading: Icon(Icons.title),
                  title: TextFormField(
                    decoration: InputDecoration(hintText: "Title"),
                    controller: _titleController,
                    onChanged: (v) => vm.entityBeingEdited!.title = v,
                    validator: (v) => v == null || v.isEmpty ? "Please enter a title" : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.content_paste),
                  title: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    decoration: InputDecoration(hintText: "Content"),
                    controller: _contentController,
                    onChanged: (v) => vm.entityBeingEdited!.content = v,
                    validator: (v) => v == null || v.isEmpty ? "Please enter content" : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.color_lens),
                  title: Row(
                    children: [
                      _colorOption(context, vm, "red"),
                      Spacer(),
                      _colorOption(context, vm, "green"),
                      Spacer(),
                      _colorOption(context, vm, "blue"),
                      Spacer(),
                      _colorOption(context, vm, "yellow"),
                      Spacer(),
                      _colorOption(context, vm, "grey"),
                      Spacer(),
                      _colorOption(context, vm, "purple"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorOption(BuildContext context, NotesViewModel vm, String color) {
    return GestureDetector(
      child: Container(
        decoration: ShapeDecoration(
          shape: Border.all(color: _getColor(color), width: 18) +
              Border.all(
                width: 6,
                color: vm.color == color ? _getColor(color) : Theme.of(context).canvasColor,
              ),
        ),
      ),
      onTap: () {
        vm.entityBeingEdited!.color = color;
        vm.setColor(color);
      },
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case "red":
        return Colors.red;
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      case "yellow":
        return Colors.yellow;
      case "grey":
        return Colors.grey;
      case "purple":
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  void _save(BuildContext context, NotesViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    await vm.save();
    _titleController.clear();
    _contentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(l10n.save_msg('Note')),
      ),
    );
  }
}
