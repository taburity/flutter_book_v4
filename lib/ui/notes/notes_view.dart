import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../data/notes_repository.dart";
import "notes_list_view.dart";
import "notes_entry_view.dart";
import "notes_view_model.dart";

class NotesView extends StatelessWidget {
  final Directory _docsDir;

  const NotesView({super.key, required Directory docsDir}) : _docsDir = docsDir;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotesViewModel>(
      create: (context) {
        NotesRepository.init(_docsDir);
        final vm = NotesViewModel();
        vm.loadNotes();
        return vm;
      },
      child: Consumer<NotesViewModel>(
        builder: (context, vm, child) {
          return IndexedStack(
            index: vm.stackIndex,
            children: [
              NotesListView(),
              NotesEntryView(),
            ],
          );
        },
      ),
    );
  }
}
