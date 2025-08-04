import "dart:io";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../domain/contact_data.dart";


class ContactsRepository {

  final Directory _docsDir;

  static late final ContactsRepository db;
  static bool _initialized = false;

  ContactsRepository._(this._docsDir);

  static void init(Directory docsDir) {
    if(!_initialized) {
      db = ContactsRepository._(docsDir);
      _initialized = true;
    }
  }

  Database? _db;

  Future<Database> get database async {
    _db ??= await initDB();
    print("## Contacts ContactsModel.get-database(): _db = $_db");
    return _db!;
  }

  Future<Database> initDB() async {
    print("Contacts ContactsModel.init()");
    String path = join(_docsDir.path, "contacts.db");
    print("## contacts ContactsModel.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS contacts ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "email TEXT,"
            "phone TEXT,"
            "birthday TEXT"
          ")"
        );
      }
    );
    return db;
  }

  ContactData contactFromMap(Map inMap) {
    print("## Contacts ContactsModel.contactFromMap(): inMap = $inMap");
    ContactData contact = ContactData(
      id: inMap["id"],
      name: inMap["name"],
      phone: inMap["phone"],
      email: inMap["email"],
      birthday: inMap["birthday"]);
    print("## Contacts ContactsModel.contactFromMap(): contact = $contact");
    return contact;
  }

  Map<String, dynamic> contactToMap(ContactData inContact) {
    print("## Contacts ContactsModel.contactToMap(): inContact = $inContact");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inContact.id;
    map["name"] = inContact.name;
    map["phone"] = inContact.phone;
    map["email"] = inContact.email;
    map["birthday"] = inContact.birthday;
    print("## Contacts ContactsModel.contactToMap(): map = $map");
    return map;
  }

  Future create(ContactData inContact) async {
    print("## Contacts ContactsModel.create(): inContact = $inContact");
    Database db = await database;
    // Get largest current id in the table, plus one, to be the new ID.
    List val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    var id = val.first["id"];
    id ??= 1;

    await db.rawInsert(
      "INSERT INTO contacts (id, name, email, phone, birthday) VALUES (?, ?, ?, ?, ?)",
      [
        id,
        inContact.name,
        inContact.email,
        inContact.phone,
        inContact.birthday
      ]
    );
    return id;
  }

  Future<ContactData> get(int inID) async {
    print("## Contacts ContactsModel.get(): inID = $inID");
    Database db = await database;
    var rec = await db.query("contacts", where : "id = ?", whereArgs : [ inID ]);
    print("## Contacts ContactsModel.get(): rec.first = $rec.first");
    return contactFromMap(rec.first);
  }

  Future<List<ContactData>> getAll() async {
    print("## Contacts ContactsModel.getAll()");
    Database db = await database;
    var recs = await db.query("contacts");
    List<ContactData> list = recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [ ];
    print("## Contacts ContactsModel.getAll(): list = $list");
    return list;
  }

  Future update(ContactData inContact) async {
    print("## Contacts ContactsModel.update(): inContact = $inContact");
    Database db = await database;
    return await db.update("contacts", contactToMap(inContact), where : "id = ?", whereArgs : [ inContact.id ]);
  }

  Future delete(int inID) async {
    print("## Contacts ContactsModel.delete(): inID = $inID");
    Database db = await database;
    return await db.delete("contacts", where : "id = ?", whereArgs : [ inID ]);
  }

}