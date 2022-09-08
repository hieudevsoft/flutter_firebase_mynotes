import 'dart:async';

import 'package:mynotes/controller/database/databases.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';
import 'database/crud_exception.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  NotesService._sharedInstance();
  static final NotesService _shared = NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    if (_db == null) {
      throw DatabaseIsNotOpened();
    } else {
      return _db!;
    }
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);
      await _db?.execute(createUserTable);
      await _db?.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory;
    }
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsNotOpened();
    } else {
      await _db?.close();
    }
  }

  Future<void> _ensureOpenDb() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //already open
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final user = await db.query(
      userTable,
      distinct: true,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (user.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {emailColumn: email},
        conflictAlgorithm: ConflictAlgorithm.replace, nullColumnHack: null);
    return DatabaseUser(id: id, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deleteCount != 1) throw CoudNotDeleteUser();
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final rows = await db.query(
      userTable,
      distinct: true,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (rows.isEmpty) throw CouldNotFindUser();
    return DatabaseUser.fromRow(rows.first);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureOpenDb();
    try {
      final user = getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final user = await getUser(email: owner.email);
    if (user != owner) throw CouldNotFindUser();
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(
        id: noteId, userId: owner.id, text: text, isSyncWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int idNote}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final deleteCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [idNote]);
    if (deleteCount != 1) throw CoudNotDeleteNote();
    final countBefore = _notes.length;
    _notes.removeWhere((note) => idNote == note.id);
    if (_notes.length != countBefore) {
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final numberOfDeleted = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeleted;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final rows = await db.query(
      noteTable,
      distinct: true,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw CouldNotFindNote();
    final note = DatabaseNote.fromRow(rows.first);
    _notes.removeWhere((element) => element.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable, orderBy: idColumn);
    if (notes.isEmpty) throw CouldNotFindNote();
    return notes.map((row) => DatabaseNote.fromRow(row)).toList();
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureOpenDb();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(noteTable, {textColumn: text},
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (updatesCount == 0) throw CouldNotUpdateNote;
    final updateNote = await getNote(id: note.id);
    _notes.removeWhere((element) => element.id == updateNote.id);
    _notes.add(updateNote);
    _notesStreamController.add(_notes);
    return updateNote;
  }
}

const createUserTable = '''
  create table if not exists "user"(
  "id" integer not null,
  "email" text not null unique,
  primary key ("id" autoincrement)
  )
''';

const createNotesTable = '''
  create table if not exists "notes"(
  "id" integer not null,
  "user_id" integer not null,
  "text" text ,
  "is_synced_with_cloud" integer not null default 0,
  foreign key("user_id") references "user"("id") ,
  primary key ("id" autoincrement)
  )
''';
