// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String greeting(Object user) {
    return 'Welcome, $user!';
  }

  @override
  String get title => 'FlutterBook';

  @override
  String get appt_title => 'Appointments';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get notes_title => 'Notes';

  @override
  String get tasks_title => 'Tasks';

  @override
  String get appt_save_msg => 'Appointment saved';

  @override
  String get contact_save_msg => 'Contact saved';

  @override
  String get note_save_msg => 'Note saved';

  @override
  String get task_save_msg => 'Task saved';

  @override
  String get appt_delete_msg => 'Appointment deleted';

  @override
  String get contact_delete_msg => 'Contact deleted';

  @override
  String get note_delete_msg => 'Note deleted';

  @override
  String get task_delete_msg => 'Task deleted';
}
