import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:provider/provider.dart";
import "../../data/notes_repository.dart";
import "../../domain/note_data.dart";
import "../../l10n/app_localizations.dart";
import "notes_view_model.dart";

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<NotesViewModel>(context, listen: false);
    return Consumer<NotesViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              vm.startEditing();
              vm.setColor('');
              vm.setStackIndex(1);
            },
          ),
          body: ListView.builder(
            itemCount: vm.notes.length,
            itemBuilder: (context, index) {
              final note = vm.notes[index];
              Color color = Colors.white;
              switch (note.color) {
                case "red":
                  color = Colors.red;
                  break;
                case "green":
                  color = Colors.green;
                  break;
                case "blue":
                  color = Colors.blue;
                  break;
                case "yellow":
                  color = Colors.yellow;
                  break;
                case "grey":
                  color = Colors.grey;
                  break;
                case "purple":
                  color = Colors.purple;
                  break;
              }
              return Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Slidable(
                  key: ValueKey(note.id),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _delete(context, note, vm),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 8,
                    color: color,
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      onTap: () async {
                        vm.startEditing(note: await NotesRepository.db.get(note.id!));
                        vm.setColor(vm.entityBeingEdited!.color);
                        vm.setStackIndex(1);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, NoteData note, NotesViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    await vm.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text(l10n.note_delete_msg),
      ),
    );
  }
}
