// lib/models/saving_goal.dart
// (100% Siap Pakai - Menambahkan copyWith)

/// Model Data untuk tabel 'SavingGoals'.
/// Fitur "Gen Z" untuk melacak progres tabungan.
class SavingGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? iconEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.iconEmoji,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8olString(),
      'icon_emoji': iconEmoji,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as double,
      currentAmount: map['current_amount'] as double,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      iconEmoji: map['icon_emoji'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// BARU: Helper copyWith untuk update yang immutable (Clean Code)
  SavingGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? iconEmoji,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}