// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'category.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    date,
    category,
  ];

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: _parseAmount(json['amount']),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      category: Category.fromJson(json['category']),
    );
  }

  static double _parseAmount(dynamic amount) {
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) return double.tryParse(amount) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category.toJson(),
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    Category? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  bool get stringify => true;
}
