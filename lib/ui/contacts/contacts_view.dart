import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../data/contacts_repository.dart";
import "contacts_list_view.dart";
import "contacts_entry_view.dart";
import "contacts_view_model.dart";

class ContactsView extends StatelessWidget {
  final Directory _docsDir;

  const ContactsView({super.key, required Directory docsDir}) : _docsDir = docsDir;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactsViewModel>(
      create: (context) {
        ContactsRepository.init(_docsDir);
        final vm = ContactsViewModel(_docsDir);
        vm.loadContacts();
        return vm;
      },
      child: Consumer<ContactsViewModel>(
        builder: (context, vm, child) {
          return IndexedStack(
            index: vm.stackIndex,
            children: [
              ContactsListView(),
              ContactsEntryView(),
            ],
          );
        },
      ),
    );
  }
}
