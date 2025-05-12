import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;
  static const int _version = 2;

  DatabaseHelper._instance();

  String transactionTable = 'transaction_table';
  String colId = 'id';
  String colType = 'type';
  String colAmount = 'amount';
  String colDate = 'date';
  String colCategory = 'category';
  String colRecurrence = 'recurrence';

  Future<Database?> get db async {
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'budget.db');
    Database db = await openDatabase(path, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
        $colRecurrence TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
        ALTER TABLE $transactionTable
        ADD COLUMN $colRecurrence TEXT
      ''');
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await this.db;
    return await db!.insert(transactionTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await this.db;
    return await db!.query(transactionTable);
  }

  Future<void> deleteTransaction(int id) async {
    Database? db = await this.db;
    await db!.delete(transactionTable, where: '$colId = ?', whereArgs: [id]);
  }
}

