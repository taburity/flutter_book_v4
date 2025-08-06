// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String greeting(Object user) {
    return 'Bem-vindo, $user!';
  }

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
  String get appt_save_msg => 'Compromisso salvo';

  @override
  String get contact_save_msg => 'Contato salvo';

  @override
  String get note_save_msg => 'Nota salva';

  @override
  String get task_save_msg => 'Tarefa salva';

  @override
  String get appt_delete_msg => 'Compromisso apagado';

  @override
  String get contact_delete_msg => 'Contato apagado';

  @override
  String get note_delete_msg => 'Nota apagada';

  @override
  String get task_delete_msg => 'Tarefa apagada';
}
