import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:path/path.dart";
import "package:provider/provider.dart";
import "../../data/contacts_repository.dart";
import "../../domain/contact_data.dart";
import "../../l10n/app_localizations.dart";
import "contacts_view_model.dart";

class ContactsListView extends StatelessWidget {
  const ContactsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ContactsViewModel>(context, listen: false);
    return Consumer<ContactsViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final avatarFile = File(join(vm.docsDir.path, "avatar"));
              if (avatarFile.existsSync()) avatarFile.deleteSync();
              vm.startEditing();
              vm.setChosenDate(null);
              vm.setStackIndex(1);
            },
          ),
          body: ListView.builder(
            itemCount: vm.contacts.length,
            itemBuilder: (context, index) {
              final contact = vm.contacts[index];
              final avatarFile = File(join(vm.docsDir.path, contact.id.toString()));
              final avatarExists = avatarFile.existsSync();
              return Slidable(
                key: ValueKey(contact.id),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _deleteContact(context, contact, vm),
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      backgroundImage: avatarExists ? FileImage(avatarFile) : null,
                      child: avatarExists
                          ? null
                          : (contact.name.isNotEmpty)
                          ? Text(contact.name.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    title: Text(contact.name),
                    subtitle: contact.phone == null ? null : Text(contact.phone!),
                    onTap: () async => _editContact(context, contact, vm),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editContact(BuildContext context, ContactData contact, ContactsViewModel vm) async {
    final avatarFile = File(join(vm.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) avatarFile.deleteSync();
    vm.startEditing(contact: await ContactsRepository.db.get(contact.id!));
    if (vm.entityBeingEdited!.birthday == null) {
      vm.setChosenDate('');
    } else {
      final parts = vm.entityBeingEdited!.birthday!.split(",");
      final birthday = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final localeName = Localizations.localeOf(context).toString();
      vm.setChosenDate(DateFormat.yMMMMd(localeName).format(birthday.toLocal()));
    }
    vm.setStackIndex(1);
  }

  Future<void> _deleteContact(BuildContext context, ContactData contact, ContactsViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    await vm.delete(contact.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text(l10n.contact_delete_msg),
      ),
    );
  }
}
