// lib/services/saving_goal_repository.dart
// (100% Siap Pakai)

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/saving_goal.dart';

class SavingGoalRepository {
  final DatabaseService _dbService = DatabaseService();
  static const String _tableName = 'SavingGoals';

  Future<void> createGoal(SavingGoal goal) async {
    final db = await _dbService.database;
    await db.insert(_tableName, goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingGoal>> getAllGoals() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'target_date ASC',
    );
    return List.generate(maps.length, (i) => SavingGoal.fromMap(maps[i]));
  }

  Future<void> updateGoal(SavingGoal goal) async {
    final db = await _dbService.database;
    await db.update(
      _tableName,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await _dbService.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}