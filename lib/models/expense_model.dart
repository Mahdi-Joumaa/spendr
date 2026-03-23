import 'package:cloud_firestore/cloud_firestore.dart';

//defining class for the exepense model

class ExpenseModel {
  final String expenseId;
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final String month; // "2026-03"
  final DateTime createdAt;

  ExpenseModel({
    required this.expenseId,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.month,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: map['expenseId'],
      amount: map['amount'].toDouble(),
      categoryId: map['categoryId'],
      note: map['note'],
      date: (map['date'] as Timestamp).toDate(),
      month: map['month'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'date': date,
      'month': month,
      'createdAt': createdAt,
    };
  }
}