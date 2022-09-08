import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, Object?> row)
      : id = row[idColumn] as int,
        email = row[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncWithCloud;
  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncWithCloud});
  DatabaseNote.fromRow(Map<String, Object?> row)
      : id = row[idColumn] as int,
        userId = row[userIdColumn] as int,
        text = row[textColumn] as String,
        isSyncWithCloud = (row[isSyncedWithCloudColumn] == 1) ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, User_Id = $userId, text = $text, isSyncWithCloud= $isSyncWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
