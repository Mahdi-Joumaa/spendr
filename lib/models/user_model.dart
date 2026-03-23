import 'package:cloud_firestore/cloud_firestore.dart';

//defining a class to know what attributes will user have and what my data looks like
class UserModel {

  //attributes
  late final String uid;
  late final String name;
  late final String email;
  late final String currency;
  late final double monthlyBudget;
  late final DateTime createdAt;

  //constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.currency, 
    required this.monthlyBudget,
    required this.createdAt
  });

  //converting data to map (firebase -> dart)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    //use factory because this isnt a normal constructor, there is logic before the concrete object is created
    return UserModel(
      // TODO: later on we will remove the default values because I will put default values in in the sign up
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      currency: map['currency'] ?? '',
      monthlyBudget: map['monthlyBudget'].toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

 //converting data to map (dart -> firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt,
    };
  }


}