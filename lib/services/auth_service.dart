import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spendr/models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  // Google Sign-In);

  //sign up
  Future<UserModel?> signUp(String name, String email, String password) async {
    //cred is for the firebase service, user is for our own model
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      currency: 'USD',
      monthlyBudget: 2000,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
    await _seedDefaultBudgets(user.uid);
    return user;
  }

  // Login
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled the sign-in

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user document exists, if not create it
    final userDoc = await _db
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!userDoc.exists) {
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'Google User',
        email: userCredential.user!.email ?? '',
        currency: 'USD',
        monthlyBudget: 2000,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());
      await _seedDefaultBudgets(newUser.uid);
      return newUser;
    }

    return UserModel.fromMap((await _db.collection('users').doc(userCredential.user!.uid).get()).data()!);}

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Auth state stream
  Stream<User?> get authState => _auth.authStateChanges();

  // Seed 7 default budget categories on signup
  Future<void> _seedDefaultBudgets(String uid) async {
    final defaults = [
      {
        'categoryId': 'food',
        'name': 'Food & Dining',
        'icon': 'restaurant',
        'colorHex': '#00C896',
        'budgetLimit': 500.0,
      },
      {
        'categoryId': 'transport',
        'name': 'Transport',
        'icon': 'directions_car',
        'colorHex': '#4D9FFF',
        'budgetLimit': 200.0,
      },
      {
        'categoryId': 'shopping',
        'name': 'Shopping',
        'icon': 'shopping_bag',
        'colorHex': '#FF79C6',
        'budgetLimit': 300.0,
      },
      {
        'categoryId': 'bills',
        'name': 'Bills',
        'icon': 'receipt',
        'colorHex': '#FFB020',
        'budgetLimit': 400.0,
      },
      {
        'categoryId': 'entertainment',
        'name': 'Entertainment',
        'icon': 'movie',
        'colorHex': '#BD93F9',
        'budgetLimit': 150.0,
      },
      {
        'categoryId': 'health',
        'name': 'Health',
        'icon': 'favorite',
        'colorHex': '#FF5C5C',
        'budgetLimit': 100.0,
      },
      {
        'categoryId': 'other',
        'name': 'Other',
        'icon': 'more_horiz',
        'colorHex': '#8A8FA8',
        'budgetLimit': 200.0,
      },
    ];
    for (final cat in defaults) {
      await _db
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(cat['categoryId'] as String)
          .set({...cat, 'createdAt': DateTime.now()});
    }
  }
}
