import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _prayerTimesDb;
  Future<Database?> get prayerTimesDb async {
    if (_prayerTimesDb != null) return _prayerTimesDb;
    _prayerTimesDb = await initialDb();
    return _prayerTimesDb;
  }

  initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'prayerTimes.db');
    // Create a database with the specified name and open it
    Database prayerTimesDb = await openDatabase(
      path,
      onCreate: _oncreate,
      version: 1,
      onUpgrade: _onupgrade,
    );
    return prayerTimesDb;
  }

  _onupgrade(Database db, int oldversion, int newversion) async {
    // Run migration according database versions
    if (oldversion < newversion) {
      // Run the migration according database versions
    }

    // ignore: avoid_print
    // print("-----------------onupgrade-----------------");
  }

  _oncreate(Database db, int version) async {
    // When creating the db, create the table
    Batch batch = db.batch();
    batch.execute('''
          CREATE TABLE prayer_times (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "response_data" TEXT NOT NULL,
          "last_updated" TEXT
          )''');

    await batch.commit();
    // ignore: avoid_print
    // print("-----------------created-----------------");
  }

  readdata(String sql) async {
    final Database? mydb = await prayerTimesDb;
    final List<Map<String, dynamic>> maps = await mydb!.rawQuery(sql);
    return List.generate(maps.length, (i) {
      return maps[i];
    });
  }

  insertdata(String sql) async {
    final Database? mydb = await prayerTimesDb;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  updatedata(String sql) async {
    final Database? mydb = await prayerTimesDb;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  deletedata(String sql) async {
    final Database? mydb = await prayerTimesDb;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}


/*
the first thing I must get the data from the new response body controller 
then I must store it in sqf lite (I need some revesion of this course)
then I need to use the old controller for handling interaction with th String data

*/