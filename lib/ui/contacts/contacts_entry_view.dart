import "dart:io";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "../../l10n/app_localizations.dart";
import "../../utils.dart" as utils;
import "contacts_view_model.dart";

class ContactsEntryView extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactsViewModel>(
      builder: (context, vm, child) {
        if (vm.entityBeingEdited != null) {
          _nameController.text = vm.entityBeingEdited!.name;
          _phoneController.text = vm.entityBeingEdited!.phone ?? '';
          _emailController.text = vm.entityBeingEdited!.email ?? '';
        }
        File avatarFile = File(join(vm.docsDir.path, "avatar"));
        if (!avatarFile.existsSync() && vm.entityBeingEdited?.id != null) {
          avatarFile = File(join(vm.docsDir.path, vm.entityBeingEdited!.id.toString()));
        }

        return Scaffold(
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ElevatedButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    final avatarTemp = File(join(vm.docsDir.path, "avatar"));
                    if (avatarTemp.existsSync()) avatarTemp.deleteSync();
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
                  title: avatarFile.existsSync()
                      ? Image.file(avatarFile)
                      : Text("No avatar image for this contact"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _selectAvatar(context, vm),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: TextFormField(
                    decoration: InputDecoration(hintText: "Name"),
                    controller: _nameController,
                    onChanged: (v) => vm.entityBeingEdited!.name = v,
                    validator: (v) => v == null || v.isEmpty ? "Please enter a name" : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: "Phone"),
                    controller: _phoneController,
                    onChanged: (v) => vm.entityBeingEdited!.phone = v,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: "Email"),
                    controller: _emailController,
                    onChanged: (v) => vm.entityBeingEdited!.email = v,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.today),
                  title: Text("Birthday"),
                  subtitle: Text(vm.chosenDate ?? ""),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () async {
                      String chosenDate = await utils.selectDate(context, vm.entityBeingEdited!.birthday);
                      vm.entityBeingEdited!.birthday = chosenDate;
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

  Future<void> _selectAvatar(BuildContext context, ContactsViewModel vm) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (image != null) {
                      final file = File(image.path);
                      final dir = await getApplicationDocumentsDirectory();
                      await file.copy(join(dir.path, "avatar"));
                      vm.triggerRebuild();
                    }
                    Navigator.of(ctx).pop();
                  },
                ),
                Padding(padding: EdgeInsets.all(10)),
                GestureDetector(
                  child: Text("Select From Gallery"),
                  onTap: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      final file = File(image.path);
                      final dir = await getApplicationDocumentsDirectory();
                      await file.copy(join(dir.path, "avatar"));
                      vm.triggerRebuild();
                    }
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context, ContactsViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    await vm.save();
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(l10n.contact_save_msg),
      ),
    );
  }
}
