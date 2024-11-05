import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_form_bloc.dart';

class ExpenseCubit extends Cubit<List<ExpenseFormBloc>> {
  ExpenseCubit() : super([]);

  void addExpense(ExpenseFormBloc expense) {
    emit([...state, expense]);
  }
}
