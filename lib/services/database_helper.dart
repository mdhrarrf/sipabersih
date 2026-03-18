import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/water_measure.dart'; // Pastikan tidak ada backslash \ di ujung

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Membuka koneksi database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sipabersih.db');
    return _database!;
  }

  // Inisialisasi file database di folder sistem HP
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Membuat tabel saat database pertama kali dibuat
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const doubleType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE water_measures (
        id $idType,
        ph $doubleType,
        tds $doubleType,
        turbidity $doubleType,
        temperature $doubleType,
        timestamp $textType
      )
    ''');
  }

  // FUNGSI: Simpan Data Baru
  Future<int> create(WaterMeasure measure) async {
    final db = await instance.database;
    return await db.insert('water_measures', measure.toMap());
  }

  // FUNGSI: Ambil Semua Data (Urutkan dari yang terbaru)
  Future<List<WaterMeasure>> readAllMeasures() async {
    final db = await instance.database;
    final result = await db.query('water_measures', orderBy: 'timestamp DESC');

    return result.map((json) => WaterMeasure.fromMap(json)).toList();
  }

  // FUNGSI: Hapus Data Berdasarkan ID (Opsional, tapi penting)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('water_measures', where: 'id = ?', whereArgs: [id]);
  }

  // Menutup database saat tidak digunakan
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
