import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spendr/models/budget_model.dart';
import 'package:spendr/models/expense_model.dart';
import 'package:spendr/models/user_model.dart';
import 'package:spendr/utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
        MaterialApp(
      theme: AppTheme.dark,
      home: ThemeTestScreen(), // test the themes 
    ),
  );
}


class ThemeTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) { // ← context exists here
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('displayLarge', style: Theme.of(context).textTheme.displayLarge),
            Text('titleLarge', style: Theme.of(context).textTheme.titleLarge),
            Text('bodyMedium', style: Theme.of(context).textTheme.bodyMedium),
            ElevatedButton(onPressed: () {}, child: Text('Primary Button')),
            SizedBox(height: 16),
            Container(height: 50, color: AppColors.primary),
            Container(height: 50, color: AppColors.danger),
            Container(height: 50, color: AppColors.card),
          ],
        ),
      ),
    );
  }
}