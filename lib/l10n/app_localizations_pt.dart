// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get title => 'AgendaFlutter';

  @override
  String get appt_title => 'Compromissos';

  @override
  String get contacts_title => 'Contatos';

  @override
  String get notes_title => 'Notas';

  @override
  String get tasks_title => 'Tarefas';

  @override
  String save_msg(Object item) {
    return '$item salvo';
  }

  @override
  String delete_msg(Object item) {
    return '$item apagado';
  }
}
