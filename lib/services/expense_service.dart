import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendr/models/expense_model.dart';

class ExpenseService {
  final _db = FirebaseFirestore.instance;

  // add expense
  Future<void> addExpense(String uid, ExpenseModel expense) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .add(expense.toMap());
  }

  //Get expenses for a month (stream)
  Stream<List<ExpenseModel>> getExpensesByMonth(String uid, String month) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('month', isEqualTo: month)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ExpenseModel.fromMap(doc.data())).toList(),
        );
  }

  // delete expense
  Future<void> deleteExpense(String uid, String expenseId) async {
  await _db
    .collection('users').doc(uid)
    .collection('expenses').doc(expenseId)
    .delete();
}

}
