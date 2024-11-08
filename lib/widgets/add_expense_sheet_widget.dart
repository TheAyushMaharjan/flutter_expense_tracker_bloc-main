import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import 'loading_widget.dart';
import 'text_form_field_widget.dart';
import '../blocs/expense_form/expense_form_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseSheetWidget extends StatelessWidget {
  const AddExpenseSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TitleFieldWidget(),
            SizedBox(height: 16),
            AmountFieldWidget(),
            SizedBox(height: 16),
            DateFieldWidget(),
            SizedBox(height: 24),
            CategoryChoicesWidget(),
            SizedBox(height: 30),
            AddButtonWidget(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class AddButtonWidget extends StatelessWidget {
  const AddButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseFormBloc>().state;
    final isLoading = state.status == ExpenseFormStatus.loading;

    return FilledButton(
      onPressed: isLoading || !state.isFormValid
          ? null
          : () async {
        // Add the expense to Firestore
        await _addExpenseToFirestore(context, state);

        // Dispatch the ExpenseSubmitted event
        context.read<ExpenseFormBloc>().add(ExpenseSubmitted());

        // After adding the expense, close the sheet
        Navigator.pop(context);
      },
      child: isLoading ? const LoadingWidget() : const Text('Add Expense'),
    );
  }

  Future<void> _addExpenseToFirestore(BuildContext context, ExpenseFormState state) async {
    try {
      final expenseData = {
        'title': state.title,
        'amount': state.amount,
        'date': state.date,
        'category': state.category.toName, // Ensure this is in a suitable format for your Category enum
      };

      // Access Firestore and add the expense data
      await FirebaseFirestore.instance.collection('expenses').add(expenseData);
    } catch (e) {
      // Handle error (e.g., show a message to the user)
      print('Error adding expense to Firestore: $e');
    }
  }
}

class DateFieldWidget extends StatelessWidget {
  const DateFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<ExpenseFormBloc>();
    final state = context.watch<ExpenseFormBloc>().state;

    final formattedDate = DateFormat('dd/MM/yyyy').format(state.date);

    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: state.date,
          firstDate: DateTime(1900),
          lastDate: DateTime(today.year + 50),
        );
        if (selectedDate != null) {
          bloc.add(ExpenseDateChanged(selectedDate));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Date',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(formattedDate, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class AmountFieldWidget extends StatelessWidget {
  const AmountFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseFormBloc>().state;

    return TextFormFieldWidget(
      label: 'Amount',
      hint: '0.00',
      prefixText: 'Rs',
      enabled: state.status != ExpenseFormStatus.loading,
      initialValue: state.amount.toString(),
      onChanged: (value) {
        context.read<ExpenseFormBloc>().add(ExpenseAmountChanged(value));
      },
    );
  }
}

class TitleFieldWidget extends StatelessWidget {
  const TitleFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseFormBloc>().state;

    return TextFormField(
      onChanged: (value) {
        context.read<ExpenseFormBloc>().add(ExpenseTitleChanged(value));
      },
      initialValue: state.title,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Expense Title',
      ),
    );
  }
}

class CategoryChoicesWidget extends StatelessWidget {
  const CategoryChoicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExpenseFormBloc>();
    final state = context.watch<ExpenseFormBloc>().state;

    return Wrap(
      spacing: 10,
      children: Category.values
          .map((category) => ChoiceChip(
        label: Text(category.toName),
        selected: category == state.category,
        onSelected: (_) => bloc.add(ExpenseCategoryChanged(category)),
      ))
          .toList(),
    );
  }
}
