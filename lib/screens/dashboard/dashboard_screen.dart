import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/spendr_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/donut_chart.dart';
import '../../widgets/expense_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  String formatMonth(String month) {
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(date).toUpperCase();
  }

  String getBudgetHealth(double totalSpent, double totalBudget) {
    if (totalBudget == 0) return 'No Budget Set';
    final ratio = totalSpent / totalBudget;
    if (ratio < 0.5) return 'Excellent';
    if (ratio < 0.75) return 'Good';
    if (ratio < 0.9) return 'Watch Out';
    return 'Over Budget';
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final spentByCategory = ref.watch(spentByCategoryProvider);
    final user = ref.watch(currentUserProvider).value;
    final currentMonth = ref.watch(currentMonthProvider);
    final formatter = NumberFormat('#,##0');

    final expenseList = expenses.value ?? [];
    final recentExpenses = expenseList.take(5).toList();
    final monthlyBudget = user?.monthlyBudget ?? 0;
    final remaining = (monthlyBudget - totalSpent).clamp(0.0, double.infinity);
    final usedPercent = monthlyBudget == 0
        ? 0.0
        : (totalSpent / monthlyBudget * 100);
    final isOverBudget = totalSpent > monthlyBudget && monthlyBudget > 0;

    return Scaffold(
      appBar: SpendrAppBar(),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_expense'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER ──────────────────────────────
              Text(
                formatMonth(currentMonth),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '\$${formatter.format(totalSpent)}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              // only show budget line if budget is set
              if (monthlyBudget > 0)
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: 'of '),
                      TextSpan(
                        text: '\$${formatter.format(monthlyBudget)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' monthly budget'),
                    ],
                  ),
                )
              else
                Text(
                  'No budget set — go to Profile to set one',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

              const SizedBox(height: 12),

              // only show progress section if budget is set
              if (monthlyBudget > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'USED ${usedPercent.clamp(0.0, 999.0).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOverBudget
                            ? AppColors.danger
                            : AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      isOverBudget
                          ? 'OVER BUDGET'
                          : '\$${formatter.format(remaining)} LEFT',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOverBudget
                            ? AppColors.danger
                            : AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (totalSpent / monthlyBudget).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      usedPercent < 75
                          ? AppColors.primary
                          : usedPercent < 90
                              ? AppColors.warning
                              : AppColors.danger,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── DONUT CHART ─────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: DonutChart(
                  spentByCategory: spentByCategory,
                  totalSpent: totalSpent,
                ),
              ),

              const SizedBox(height: 28),

              // ── RECENT TRANSACTIONS ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    child: Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              expenses.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No expenses yet this month',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: recentExpenses
                        .map((expense) => ExpenseTile(expense: expense))
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text(
                  'Error loading expenses',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}