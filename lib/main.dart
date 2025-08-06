import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:path_provider/path_provider.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import "l10n/app_localizations.dart";
import "ui/appointments/appointments_view.dart";
import "ui/contacts/contacts_view.dart";
import "ui/notes/notes_view.dart";
import "ui/tasks/tasks_view.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  print("## main(): FlutterBook Starting");
  Directory docsDir = await startMeUp();
  runApp(FlutterBook(docsDir: docsDir));
}

Future<Directory> startMeUp() async {
  return await getApplicationDocumentsDirectory();
}

class FlutterBook extends StatelessWidget {
  final Directory _docsDir;

  const FlutterBook({super.key, required Directory docsDir}) : _docsDir = docsDir;

  @override
  Widget build(BuildContext context) {
    print("## FlutterBook.build()");
    return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('pt', 'BR'),
        ],
        localeResolutionCallback: (locale, supportedLocales){
          for(var sl in supportedLocales){
            if(sl.languageCode == locale!.languageCode &&
                sl.languageCode==locale.languageCode){
              return locale;
            }
          }
          return supportedLocales.first;
        },
        // locale: const Locale('en'),
        locale: const Locale('pt', 'BR'),
        home : Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return DefaultTabController(
                length : 4,
                child : Scaffold(
                    appBar : AppBar(
                        title : Text(l10n.title),
                        bottom : TabBar(
                            tabs : [
                              Tab(icon : Icon(Icons.date_range), text : l10n.appt_title),
                              Tab(icon : Icon(Icons.contacts), text : l10n.contacts_title),
                              Tab(icon : Icon(Icons.note), text : l10n.notes_title),
                              Tab(icon : Icon(Icons.assignment_turned_in), text : l10n.tasks_title)
                            ])),
                    body : TabBarView(
                        children : [
                          Appointments(docsDir: _docsDir),
                          ContactsView(docsDir: _docsDir),
                          NotesView(docsDir: _docsDir),
                          TasksView(docsDir: _docsDir)
                        ],
                    ),
                ),
            );
          },
        ),
    );
  }
}