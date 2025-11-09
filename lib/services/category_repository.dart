// lib/services/category_repository.dart
// (100% Siap Pakai)

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseService _dbService = DatabaseService();
  static const String _tableName = 'Categories';

  Future<void> createCategory(Category category) async {
    final db = await _dbService.database;
    await db.insert(_tableName, category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Mengambil semua kategori, dipisah berdasarkan Tipe (income/expense)
  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
  
  // (Tambahkan fungsi update/delete di sini jika diperlukan)
}