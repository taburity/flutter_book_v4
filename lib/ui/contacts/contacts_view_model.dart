import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import '../../data/contacts_repository.dart';
import '../../domain/contact_data.dart';

class ContactsViewModel extends ChangeNotifier {
  int _stackIndex = 0;
  int get stackIndex => _stackIndex;
  List<ContactData> _contacts = [];
  List<ContactData> get contacts => _contacts;
  ContactData? entityBeingEdited;
  String? chosenDate;
  final Directory docsDir;

  ContactsViewModel(this.docsDir);

  Future<void> loadContacts() async {
    _contacts = await ContactsRepository.db.getAll();
    notifyListeners();
  }

  void startEditing({ContactData? contact}) {
    entityBeingEdited = contact ?? ContactData(name: '');
    notifyListeners();
  }

  void setChosenDate(String? date) {
    chosenDate = date;
    notifyListeners();
  }

  void setStackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  Future<void> save() async {
    if (entityBeingEdited == null) return;
    if (entityBeingEdited!.id == null) {
      var id = await ContactsRepository.db.create(entityBeingEdited!);
      _renameTempAvatar(id);
    } else {
      await ContactsRepository.db.update(entityBeingEdited!);
      _renameTempAvatar(entityBeingEdited!.id!);
    }
    await loadContacts();
    setStackIndex(0);
  }

  Future<void> delete(int id) async {
    final avatarFile = File(join(docsDir.path, id.toString()));
    if (avatarFile.existsSync()) avatarFile.deleteSync();
    await ContactsRepository.db.delete(id);
    await loadContacts();
  }

  void _renameTempAvatar(int id) {
    final avatarFile = File(join(docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(docsDir.path, id.toString()));
    }
  }

  void triggerRebuild() {
    notifyListeners();
  }
}
