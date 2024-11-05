import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_bloc/data/local_data_storage.dart';
import 'package:flutter_expense_tracker_bloc/repositories/expense_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure you have the right options for initialization
  );

  // Initialize SharedPreferences
  final preferences = await SharedPreferences.getInstance();
  final storage = LocalDataStorage(preferences: preferences);

  // Initialize the expense repository
  final expenseRepository = ExpenseRepository(storage: storage);

  // Run the app
  runApp(App(expenseRepository: expenseRepository));
}
