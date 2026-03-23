import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendr/models/budget_model.dart';

class BudgetService {
  final _db = FirebaseFirestore.instance;

  // get all budgets (stream)
  Stream<List<BudgetModel>> getBudgets(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList(),
        );
  }

  // Update budget limit
  Future<void> updateBudgetLimit(
    String uid,
    String categoryId,
    double newLimit,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(categoryId)
        .update({'budgetLimit': newLimit});
  }
}
