import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendr/providers/auth_provider.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';


final expenseServiceProvider = Provider((ref) => ExpenseService());

final currentMonthProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final expensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final month = ref.watch(currentMonthProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(expenseServiceProvider).getExpensesByMonth(uid, month);
});

final totalSpentProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});

final spentByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final Map<String, double> map = {};
  for (final e in expenses) {
    map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
  }
  return map;
});