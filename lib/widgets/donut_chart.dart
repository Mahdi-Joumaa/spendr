import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DonutChart extends StatelessWidget {
  final Map<String, double> spentByCategory;
  final double totalSpent;

  const DonutChart({
    Key? key,
    required this.spentByCategory,
    required this.totalSpent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // empty state
    if (totalSpent == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No expenses this month',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final sections = spentByCategory.entries.map((entry) {
      final color =
          AppColors.categoryColors[entry.key] ?? AppColors.textSecondary;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 30,
        showTitle: false,
      );
    }).toList();

    return Column(
      children: [
        // donut chart
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 90,
                  sectionsSpace: 3,
                  startDegreeOffset: -90,
                ),
              ),
              // center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '\$${totalSpent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // legend — 2 columns grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: spentByCategory.entries.map((entry) {
              final color =
                  AppColors.categoryColors[entry.key] ?? AppColors.textSecondary;
              final percentage =
                  (entry.value / totalSpent * 100).toStringAsFixed(0);

              return SizedBox(
                width: 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // colored dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // category name + percentage
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}