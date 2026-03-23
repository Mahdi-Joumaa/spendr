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
 
  runApp(MaterialApp(
    home: Container(
      child: Text('Spendr'),
    ),
  ));
}


