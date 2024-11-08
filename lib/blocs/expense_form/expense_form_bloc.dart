import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_expense_tracker_bloc/models/category.dart';
import 'package:flutter_expense_tracker_bloc/models/expense.dart';
import 'package:flutter_expense_tracker_bloc/repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';

part 'expense_form_event.dart';
part 'expense_form_state.dart';

class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  ExpenseFormBloc({
    required ExpenseRepository repository,
    Expense? initialExpense,
  })  : _repository = repository,
        super(ExpenseFormState(
        initialExpense: initialExpense,
        title: initialExpense?.title,
        amount: initialExpense?.amount,
        date: initialExpense?.date ?? DateTime.now(),
        category: initialExpense?.category ?? Category.other,
      )) {
    on<ExpenseTitleChanged>(_onTitleChanged);
    on<ExpenseAmountChanged>(_onAmountChanged);
    on<ExpenseDateChanged>(_onDateChanged);
    on<ExpenseCategoryChanged>(_onCategoryChanged);
    on<ExpenseSubmitted>(_onSubmitted);
  }

  final ExpenseRepository _repository;

  void _onTitleChanged(
      ExpenseTitleChanged event,
      Emitter<ExpenseFormState> emit,
      ) {
    emit(state.copyWith(title: event.title));
  }

  void _onAmountChanged(
      ExpenseAmountChanged event,
      Emitter<ExpenseFormState> emit,
      ) {
    try {
      final amount = double.parse(event.amount);
      emit(state.copyWith(amount: amount));
    } catch (e) {
      emit(state.copyWith(
          amount: 0.0, error: 'Invalid amount. Please enter a valid number.'));
    }
  }

  void _onDateChanged(
      ExpenseDateChanged event,
      Emitter<ExpenseFormState> emit,
      ) {
    emit(state.copyWith(date: event.date));
  }

  void _onCategoryChanged(
      ExpenseCategoryChanged event,
      Emitter<ExpenseFormState> emit,
      ) {
    emit(state.copyWith(category: event.category));
  }

  Future<void> _onSubmitted(
      ExpenseSubmitted event,
      Emitter<ExpenseFormState> emit,
      ) async {
    emit(state.copyWith(status: ExpenseFormStatus.loading));

    try {
      final expense = (state.initialExpense)?.copyWith(
        title: state.title,
        amount: state.amount,
        date: state.date,
        category: state.category,
      ) ??
          Expense(
            id: const Uuid().v4(),
            title: state.title ?? 'Untitled',
            amount: state.amount ?? 0.0,
            date: state.date,
            category: state.category,
          );

      await _repository.createExpense(expense);
      emit(state.copyWith(status: ExpenseFormStatus.success));

      // Reset form to initial state after successful submission
      emit(ExpenseFormState(
        date: DateTime.now(),
        status: ExpenseFormStatus.initial,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseFormStatus.failure,
        error: 'Failed to save expense. Please try again.',
      ));
    }
  }
}
