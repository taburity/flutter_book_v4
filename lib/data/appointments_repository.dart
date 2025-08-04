import "dart:io";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../domain/appointment_data.dart";


class AppointmentsRepository {

  final Directory _docsDir;

  static late final AppointmentsRepository db;
  static bool _initialized = false;

  AppointmentsRepository._(this._docsDir);

  static void init(Directory docsDir) {
    if(!_initialized) {
      db = AppointmentsRepository._(docsDir);
      _initialized = true;
    }
  }

  Database? _db;

  Future<Database> get database async {
    _db ??= await initDB();
    print("## appointments AppointmentsModel.get-database(): _db = $_db");
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(_docsDir.path, "appointments.db");
    print("## appointments AppointmentsModel.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS appointments ("
            "id INTEGER PRIMARY KEY,"
            "title TEXT,"
            "description TEXT,"
            "apptDate TEXT,"
            "apptTime TEXT"
          ")"
        );
      }
    );
    return db;
  }

  AppointmentData appointmentFromMap(Map inMap) {
    print("## appointments AppointmentsModel.appointmentFromMap(): inMap = $inMap");
    AppointmentData appointment = AppointmentData(
      id: inMap["id"],
      title: inMap["title"],
      description: inMap["description"],
      apptDate: inMap["apptDate"],
      apptTime: inMap["apptTime"]
    );
    print("## appointments AppointmentsModel.appointmentFromMap(): appointment_data.dart = $appointment");
    return appointment;
  }

  Map<String, dynamic> appointmentToMap(AppointmentData inAppointment) {
    print("## appointments AppointmentsModel.appointmentToMap(): inAppointment = $inAppointment");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inAppointment.id;
    map["title"] = inAppointment.title;
    map["description"] = inAppointment.description;
    map["apptDate"] = inAppointment.apptDate;
    map["apptTime"] = inAppointment.apptTime;
    print("## appointments AppointmentsModel.appointmentToMap(): map = $map");
    return map;
  }

  Future create(AppointmentData inAppointment) async {
    print("## appointments AppointmentsModel.create(): inAppointment = $inAppointment");
    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    List val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    var id = val.first["id"];
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO appointments (id, title, description, apptDate, apptTime) VALUES (?, ?, ?, ?, ?)",
      [
        id,
        inAppointment.title,
        inAppointment.description,
        inAppointment.apptDate,
        inAppointment.apptTime
      ]
    );
  }

  Future<AppointmentData> get(int inID) async {
    print("## appointments AppointmentsModel.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("appointments", where : "id = ?", whereArgs : [ inID ]);
    print("## appointments AppointmentsModel.get(): rec.first = $rec.first");
    return appointmentFromMap(rec.first);
  }

  Future<List<AppointmentData>> getAll() async {
    Database db = await database;
    var recs = await db.query("appointments");
    List<AppointmentData> list = recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [ ];
    print("## appointments AppointmentsModel.getAll(): list = $list");
    return list;
  }

  Future update(AppointmentData inAppointment) async {
    print("## appointments AppointmentsModel.update(): inAppointment = $inAppointment");
    Database db = await database;
    return await db.update(
      "appointments", appointmentToMap(inAppointment), where : "id = ?", whereArgs : [ inAppointment.id ]
    );
  }

  Future delete(int inID) async {
    print("## appointments AppointmentsModel.delete(): inID = $inID");
    Database db = await database;
    return await db.delete("appointments", where : "id = ?", whereArgs : [ inID ]);
  }

}