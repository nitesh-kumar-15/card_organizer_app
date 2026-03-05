// cardRepository exposes high level crud operations for cards
import '../helpers/database_helper.dart'; // adjust path if file is moved
import '../models/card.dart';
import 'package:sqflite/sqflite.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // create - insert a new card
  Future<int> insertCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return await db.insert('cards', card.toMap());
  }

  // read - get all cards
  Future<List<PlayingCard>> getAllCards() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cards');

    return List.generate(maps.length, (i) {
      return PlayingCard.fromMap(maps[i]);
    });
  }

  // read - get cards by folder id
  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'card_name ASC',
    );

    return List.generate(maps.length, (i) {
      return PlayingCard.fromMap(maps[i]);
    });
  }

  // read - get a single card by id
  Future<PlayingCard?> getCardById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PlayingCard.fromMap(maps.first);
  }

  // update - persist changes to an existing card
  Future<int> updateCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // delete - remove a single card
  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // get card count for a specific folder
  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // move a card to a different folder
  Future<int> moveCardToFolder(int cardId, int newFolderId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cards',
      {'folder_id': newFolderId},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }
}