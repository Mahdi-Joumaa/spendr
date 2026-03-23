import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendr/providers/auth_provider.dart';
import '../services/budget_service.dart';
import '../models/budget_model.dart';

final budgetServiceProvider = Provider((ref) => BudgetService());

final budgetsProvider = StreamProvider<List<BudgetModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(budgetServiceProvider).getBudgets(uid);
});