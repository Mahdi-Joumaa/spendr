// TESTS FOR SERVICES 

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   final authService = AuthService();
//   final expenseService = ExpenseService();

//   // ─────────────────────────────────────
//   // test signup
//   // ─────────────────────────────────────
//   print('testing signup...');
//   try {
//     final user = await authService.signUp(
//       'Julian Walters',
//       'julian@spendr.com',
//       'password123',
//     );
//     print('signup worked, uid: ${user?.uid}');
//     print('name: ${user?.name}');
//     print('currency: ${user?.currency}');
//     print('monthly budget: ${user?.monthlyBudget}');

//     final uid = user!.uid;

//     // ─────────────────────────────────────
//     // test addExpense
//     // ─────────────────────────────────────
//     print('');
//     print('testing addExpense...');
//     final expense = ExpenseModel(
//       expenseId: 'test-expense-1',
//       amount: 15.00,
//       categoryId: 'food',
//       note: 'coffee from artisan',
//       date: DateTime.now(),
//       month: '2026-03',
//       createdAt: DateTime.now(),
//     );
//     await expenseService.addExpense(uid, expense);
//     print('expense added, go check firebase console');

//     // ─────────────────────────────────────
//     // test getExpensesByMonth stream
//     // ─────────────────────────────────────
//     print('');
//     print('testing stream...');
//     expenseService.getExpensesByMonth(uid, '2026-03').listen((expenses) {
//       print('stream fired, got ${expenses.length} expenses');
//       for (final e in expenses) {
//         print('  ${e.note} - \$${e.amount} - ${e.categoryId}');
//       }
//     });

//     // ─────────────────────────────────────
//     // test deleteExpense
//     // ─────────────────────────────────────
//     await Future.delayed(Duration(seconds: 2));
//     print('');
//     print('testing deleteExpense...');
//     await expenseService.deleteExpense(uid, 'test-expense-1');
//     print('expense deleted, stream should fire again with 0 expenses');

//     // ─────────────────────────────────────
//     // test login
//     // ─────────────────────────────────────
//     await Future.delayed(Duration(seconds: 2));
//     print('');
//     print('testing logout then login...');
//     await authService.logout();
//     print('logged out');

//     await authService.login('julian@spendr.com', 'password123');
//     print('logged back in');

//     // test wrong password
//     print('');
//     print('testing wrong password...');
//     try {
//       await authService.login('julian@spendr.com', 'wrongpassword');
//     } catch (e) {
//       print('wrong password caught correctly: $e');
//     }

//   } catch (e) {
//     print('something failed: $e');
//   }
// }


