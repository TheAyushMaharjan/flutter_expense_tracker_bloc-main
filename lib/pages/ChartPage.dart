import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchWeeklyExpenses() async {
    final expensesSnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .get();

    final List<String> daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    List<Map<String, dynamic>> weeklyExpenses = List.generate(7, (index) => {
      'day': daysOfWeek[index],
      'amount': 0.0,
      'titles': '',
      'color': Colors.blue,
    });

    for (var doc in expensesSnapshot.docs) {
      final expenseData = doc.data();
      final date = (expenseData['date'] as Timestamp).toDate();
      final amount = expenseData['amount'] as double;
      final title = expenseData['title'] ?? 'Expense';

      int weekday = date.weekday - 1; // 0 = Monday, 6 = Sunday
      if (weekday >= 0 && weekday < 7) {
        // Accumulate the amount for the weekday
        weeklyExpenses[weekday]['amount'] += amount;

        // Concatenate the titles with a comma if there are multiple titles for the same day
        if (weeklyExpenses[weekday]['titles'].isNotEmpty) {
          weeklyExpenses[weekday]['titles'] += ', $title';
        } else {
          weeklyExpenses[weekday]['titles'] = title;
        }
      }
    }

    return weeklyExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Expenses Chart'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchWeeklyExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }
                final weeklyExpenses = snapshot.data ?? [];

                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildChartSection(weeklyExpenses, constraints.maxWidth),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildLegendListView(weeklyExpenses),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartSection(List<Map<String, dynamic>> weeklyExpenses, double maxWidth) {
    return Column(
      children: [
        const SizedBox(height: 50), // Add spacing above the chart section
        const Text(
          'Weekly Expenses Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: maxWidth > 600 ? 350 : 250, // Increase chart size based on screen width
          child: PieChart(
            PieChartData(
              sections: _buildPieSections(weeklyExpenses, maxWidth),
              centerSpaceRadius: maxWidth > 600 ? 50 : 40, // Adjust center space radius
              sectionsSpace: 4,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(List<Map<String, dynamic>> weeklyExpenses, double maxWidth) {
    final total = weeklyExpenses.fold(0.0, (sum, item) => sum + (item['amount'] as double));
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ]; // Unique colors for each day of the week

    return List.generate(weeklyExpenses.length, (index) {
      final value = weeklyExpenses[index]['amount'] as double;
      final percentage = (total == 0) ? 0 : (value / total) * 100;
      weeklyExpenses[index]['color'] = colors[index % colors.length];

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: maxWidth > 600 ? 90 : 90, // Increase radius for a larger pie chart
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Widget _buildLegendListView(List<Map<String, dynamic>> weeklyExpenses) {
    return SizedBox(
      width: 200, // Adjust width for better readability
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: weeklyExpenses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  color: weeklyExpenses[index]['color'],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weeklyExpenses[index]['day']} (Rs ${weeklyExpenses[index]['amount'].toStringAsFixed(2)})', // Show day and amount
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weeklyExpenses[index]['titles'], // Show titles for that day
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
