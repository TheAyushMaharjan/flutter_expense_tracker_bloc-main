part of 'expense_form_bloc.dart';

enum ExpenseFormStatus { initial, loading, success, failure }

extension ExpenseFormStatusX on ExpenseFormStatus {
  bool get isLoading => this == ExpenseFormStatus.loading;
  bool get isSuccess => this == ExpenseFormStatus.success;
  bool get isFailure => this == ExpenseFormStatus.failure;
}

final class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.title,
    this.amount,
    required this.date,
    this.category = Category.other,
    this.status = ExpenseFormStatus.initial,
    this.initialExpense,
    this.error = '',
  });

  final String? title;
  final double? amount;
  final DateTime date;
  final Category category;
  final ExpenseFormStatus status;
  final Expense? initialExpense;
  final String error; // Add error field for error messages

  ExpenseFormState copyWith({
    String? title,
    double? amount,
    DateTime? date,
    Category? category,
    ExpenseFormStatus? status,
    Expense? initialExpense,
    String? error,
  }) {
    return ExpenseFormState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      status: status ?? this.status,
      initialExpense: initialExpense ?? this.initialExpense,
      error: error ?? this.error, // Include error in copyWith
    );
  }

  @override
  List<Object?> get props => [
    title,
    amount,
    date,
    category,
    status,
    initialExpense,
    error,
  ];

  bool get isFormValid => title != null && title!.isNotEmpty && amount != null && amount! > 0;
}
