import 'package:cloud_firestore/cloud_firestore.dart';

// defining the budget model class

class BudgetModel {
  final String categoryId;
  final String name;
  final String icon;
  final String colorHex;
  final double budgetLimit;
  final DateTime createdAt;

  BudgetModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.budgetLimit,
    required this.createdAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      categoryId: map['categoryId'],
      name: map['name'],
      icon: map['icon'],
      colorHex: map['colorHex'],
      budgetLimit: map['budgetLimit'].toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'colorHex': colorHex,
      'budgetLimit': budgetLimit,
      'createdAt': createdAt,
    };
  }

  //for testing
  @override
  String toString() {
    return 'BudgetModel(categoryId: $categoryId, name: $name, icon: $icon, colorHex: $colorHex, budgetLimit: $budgetLimit)';
  }
}
