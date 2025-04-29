import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String transactionTable = 'transaction_table';
  String colId = 'id';
  String colType = 'type';
  String colAmount = 'amount';
  String colDate = 'date';
  String colCategory = 'category';

  Future<Database?> get db async {
    // if (_db == null) {
    //   _db = await _initDb();
    // }
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'budget.db');
    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colType TEXT,
        $colAmount REAL,
        $colDate TEXT,
        $colCategory TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await this.db;
    return await db!.insert(transactionTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await this.db;
    return await db!.query(transactionTable);
  }
}

