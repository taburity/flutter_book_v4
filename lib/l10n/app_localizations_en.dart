// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String save_msg(Object item) {
    return '$item saved';
  }

  @override
  String delete_msg(Object item) {
    return '$item deleted';
  }
}
