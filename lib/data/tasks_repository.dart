import "dart:io";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../domain/task_data.dart";


class TasksRepository {

  final Directory _docsDir;

  static late final TasksRepository db;
  static bool _initialized = false;

  TasksRepository._(this._docsDir);

  static void init(Directory docsDir) {
    if(!_initialized) {
      db = TasksRepository._(docsDir);
      _initialized = true;
    }
  }

  Database? _db;

  Future get database async {
    _db ??= await initDB();
    print("## tasks TasksModel.get-database(): _db = $_db");
    return _db!;
  }

  Future<Database> initDB() async {
    print("## Tasks TasksModel.init()");
    String path = join(_docsDir.path, "tasks.db");
    print("## tasks TasksModel.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS tasks ("
            "id INTEGER PRIMARY KEY,"
            "description TEXT,"
            "dueDate TEXT,"
            "completed TEXT"
          ")"
        );
      }
    );
    return db;
  }

  TaskData taskFromMap(Map inMap) {
    print("## Tasks TasksModel.taskFromMap(): inMap = $inMap");
    TaskData task = TaskData(
      id: inMap["id"],
      description: inMap["description"],
      dueDate: inMap["dueDate"],
      completed: inMap["completed"]);
    print("## Tasks TasksModel.taskFromMap(): task = $task");
    return task;
  }

  Map<String, dynamic> taskToMap(TaskData inTask) {
    print("## tasks TasksModel.taskToMap(): inTask = $inTask");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inTask.id;
    map["description"] = inTask.description;
    map["dueDate"] = inTask.dueDate;
    map["completed"] = inTask.completed;
    print("## tasks TasksModel.taskToMap(): map = $map");
    return map;
  }

  Future create(TaskData inTask) async {
    print("## Tasks TasksModel.create(): inTask = $inTask");
    Database db = await database;
    // Get largest current id in the table, plus one, to be the new ID.
    List val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    var id = val.first["id"];
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO tasks (id, description, dueDate, completed) VALUES (?, ?, ?, ?)",
      [
        id,
        inTask.description,
        inTask.dueDate,
        inTask.completed
      ]
    );
  }

  Future<TaskData> get(int inID) async {
    print("## Tasks TasksModel.get(): inID = $inID");
    Database db = await database;
    var rec = await db.query("tasks", where : "id = ?", whereArgs : [ inID ]);
    print("## Tasks TasksModel.get(): rec.first = $rec.first");
    return taskFromMap(rec.first);
  }

  Future<List<TaskData>> getAll() async {
    print("## Tasks TasksModel.getAll()");
    Database db = await database;
    var recs = await db.query("tasks");
    List<TaskData> list = recs.isNotEmpty ? recs.map((m) => taskFromMap(m)).toList() : [ ];
    print("## Tasks TasksModel.getAll(): list = $list");
    return list;
  }

  Future update(TaskData inTask) async {
    print("## Tasks TasksModel.update(): inTask = $inTask");
    Database db = await database;
    return await db.update("tasks", taskToMap(inTask), where : "id = ?", whereArgs : [ inTask.id ]);
  }

  Future delete(int inID) async {
    print("## Taasks TasksModel.delete(): inID = $inID");
    Database db = await database;
    return await db.delete("Tasks", where : "id = ?", whereArgs : [ inID ]);
  }

}