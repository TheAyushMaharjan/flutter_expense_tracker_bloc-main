part of 'expense_form_bloc.dart';

sealed class ExpenseFormEvent extends Equatable {
  const ExpenseFormEvent();

  @override
  List<Object> get props => [];
}

final class ExpenseTitleChanged extends ExpenseFormEvent {
  final String title;

  const ExpenseTitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

final class ExpenseAmountChanged extends ExpenseFormEvent {
  final String amount;

  const ExpenseAmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

final class ExpenseDateChanged extends ExpenseFormEvent {
  final DateTime date;

  const ExpenseDateChanged(this.date);

  @override
  List<Object> get props => [date];
}

final class ExpenseCategoryChanged extends ExpenseFormEvent {
  final Category category;

  const ExpenseCategoryChanged(this.category);

  @override
  List<Object> get props => [category];
}

final class ExpenseSubmitted extends ExpenseFormEvent {
  const ExpenseSubmitted();
}
