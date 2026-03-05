// folderRepository exposes high level crud operations for folders
import '../helpers/database_helper.dart'; // adjust path if file is moved
import '../models/folder.dart';
import 'package:sqflite/sqflite.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // create - insert a new folder
  Future<int> insertFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.insert('folders', folder.toMap());
  }

  // read - get all folders
  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('folders');

    return List.generate(maps.length, (i) {
      return Folder.fromMap(maps[i]);
    });
  }

  // read - get a single folder by id
  Future<Folder?> getFolderById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Folder.fromMap(maps.first);
  }

  // update - persist changes to an existing folder
  Future<int> updateFolder(Folder folder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  // delete - remove a folder and its cards (via cascade)
  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    // Due to ON DELETE CASCADE, this will also delete all cards
    return await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // get folder count
  Future<int> getFolderCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM folders');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}