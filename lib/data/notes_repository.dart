import "dart:io";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../domain/note_data.dart";


class NotesRepository {
  final Directory _docsDir;

  static late final NotesRepository db;
  static bool _initialized = false;

  NotesRepository._(this._docsDir);

  static void init(Directory docsDir) {
    if(!_initialized) {
      db = NotesRepository._(docsDir);
      _initialized = true;
    }
  }

  Database? _db;

  Future get database async {
    _db ??= await initDB();
    print("## Notes NotesModel.get-database(): _db = $_db");
    return _db!;
  }

  Future<Database> initDB() async {
    print("Notes NotesModel.init()");
    String path = join(_docsDir.path, "notes.db");
    print("## notes NotesModel.init(): path = $path");

    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS notes ("
            "id INTEGER PRIMARY KEY,"
            "title TEXT,"
            "content TEXT,"
            "color TEXT"
          ")"
        );
      }
    );
    return db;
  }

  NoteData noteFromMap(Map inMap) {
    print("## Notes NotesModel.noteFromMap(): inMap = $inMap");
    NoteData note = NoteData(
      id: inMap["id"],
      title: inMap["title"],
      content: inMap["content"],
      color: inMap["color"]);
    print("## Notes NotesModel.noteFromMap(): note = $note");
    return note;
  }

  Map<String, dynamic> noteToMap(NoteData inNote) {
    print("## Notes NotesModel.noteToMap(): inNote = $inNote");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inNote.id;
    map["title"] = inNote.title;
    map["content"] = inNote.content;
    map["color"] = inNote.color;
    print("## notes NotesModel.noteToMap(): map = $map");
    return map;
  }

  Future create(NoteData inNote) async {
    print("## Notes NotesModel.create(): inNote = $inNote");
    Database db = await database;

    List val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    var id = val.first["id"];
    id ??= 1;

    return await db.insert('notes', noteToMap(inNote));
  }

  Future<NoteData> get(int inID) async {
    print("## Notes NotesModel.get(): inID = $inID");
    Database db = await database;
    var rec = await db.query("notes", where : "id = ?", whereArgs : [ inID ]);
    print("## Notes NotesModel.get(): rec.first = $rec.first");
    return noteFromMap(rec.first);
  }

  Future<List<NoteData>> getAll() async {
    print("## Notes NotesModel.getAll()");
    Database db = await database;
    var recs = await db.query("notes");
    List<NoteData> list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [ ];
    print("## Notes NotesModel.getAll(): list = $list");
    return list;
  }

  Future update(NoteData inNote) async {
    print("## Notes NotesModel.update(): inNote = $inNote");
    Database db = await database;
    return await db.update("notes",
        noteToMap(inNote), where : "id = ?", whereArgs : [ inNote.id ]);
  }

  Future delete(int inID) async {
    print("## Notes NotesModel.delete(): inID = $inID");
    Database db = await database;
    return await db.delete("notes", where : "id = ?", whereArgs : [ inID ]);
  }
}
