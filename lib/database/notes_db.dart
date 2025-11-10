import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// MODEL ==========================================================
class Notes {
  int? id;
  String title;
  String content;
  DateTime createdTime;
  Notes({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
  });

  // FROM JSON
  static Notes fromJson(Map<String, Object?> json) => Notes(
    id: json['id'] as int,
    title: json['title'] as String,
    content: json['content'] as String,
    createdTime: DateTime.parse(json['createdTime'] as String),
  );

  // TO JSON
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdTime': createdTime.toIso8601String(),
  };

  // COPY
  Notes copy({
    int? id,
    String? title,
    String? content,
    DateTime? createdTime,
  }) => Notes(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdTime: createdTime ?? this.createdTime,
  );
}

// DATABASE =======================================================
class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;
  NoteDatabase._init();
  // GET DATABASE
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("notes.db");
    return _database!;
  }

  // INITILAIZATION
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // CREATE DATABASE
  Future _createDB(Database db, int version) async {
    await db.execute("""
    CREATE TABLE notes(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    createdTime TEXT NOT NULL
    )""");
  }

  // CREATE NOTE
  Future<Notes> create(Notes note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toJson());
    return note.copy(id: id);
  }

  // READ NOTE WITH ID
  Future<Notes> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'title', 'content', 'createdTime'],
      where: 'id = ?',
      whereArgs: [id],
    );
    return Notes.fromJson(maps.first);
  }

  // READ ALL NOTE
  Future<List<Notes>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createdTime DESC');
    return result.map((json) => Notes.fromJson(json)).toList();
  }

  // UPDATE NOTE WITH ID
  Future<int> update(Notes note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE NOTE WITH ID
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // CLOSE DATABASE
  Future<void> closeDB() async {
    final db = await instance.database;
    await db.close();
  }
}
