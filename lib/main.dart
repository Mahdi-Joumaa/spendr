import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spendr/models/budget_model.dart';
import 'package:spendr/models/expense_model.dart';
import 'package:spendr/models/user_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //test the models

  //testing the user model
  final userTest = {
    'uid': 'user-abc123',
    'name': 'Julian Walters',
    'email': 'julian@spendr.com',
    'currency': 'USD',
    'monthlyBudget': 4500.0,
    'createdAt': Timestamp.now(),
  };
  final user = UserModel.fromMap(userTest);
  print(user);
  final userBackToMap = user.toMap();
  print(userBackToMap);

  //testing the expense model
  final Map<String, dynamic> expenseTest = {
    'expenseId': 'test-123',
    'amount': 24.50,
    'categoryId': 'food',
    'note': 'Test expense',
    'date': Timestamp.now(),
    'month': '2026-03',
    'createdAt': Timestamp.now(),
  };
  final expense = ExpenseModel.fromMap(expenseTest);
  print(expense);
  final expenseToMap = expense.toMap();
  print(expenseToMap);
 
  //test the budget model
  final budgetTest = {
    'categoryId': 'food',
    'name': 'Food & Dining',
    'icon': 'restaurant',
    'colorHex': '#00C896',
    'budgetLimit': 500.0,
    'createdAt': Timestamp.now(),
  };
  final budget = BudgetModel.fromMap(budgetTest);
  print(budget);
  final budgetBackToMap = budget.toMap();
  print(budgetBackToMap);
  

  runApp(MaterialApp(
    home: Container(
      child: Text('Spendr'),
    ),
  ));
}


