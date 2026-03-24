import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendr/providers/auth_provider.dart';
import 'package:spendr/providers/budget_provider.dart';
import 'package:spendr/providers/expense_provider.dart';
import 'package:spendr/utils/theme.dart';
import 'package:spendr/widgets/spendr_app_bar.dart';
import 'package:spendr/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final budgets = ref.watch(budgetsProvider);
    final spentByCategory = ref.watch(spentByCategoryProvider);
    final user = ref.watch(currentUserProvider).value;
    final currentMonth = ref.watch(currentMonthProvider);
    final savings = user?.monthlyBudget ?? 0 - totalSpent;

    

    //date converter
    String formatMonth(String month) {
      final parts = month.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMMM yyyy').format(date).toUpperCase();
    }

    //budget formatter
    final formatter = NumberFormat('#,##0');

    String getBudgetHealth(double totalSpent, double totalBudget) {
      if (totalBudget == 0) return 'No Budget Set';
      final ratio = totalSpent / totalBudget;
      if (ratio < 0.5) return 'Excellent';
      if (ratio < 0.75) return 'Good';
      if (ratio < 0.9) return 'Watch Out';
      return 'Over Budget';
    }

    Color getBudgetHealthColor(double totalSpent, double totalBudget) {
      if (totalBudget == 0) return AppColors.textSecondary;
      final ratio = totalSpent / totalBudget;
      if (ratio < 0.5) return AppColors.primary;
      if (ratio < 0.75) return AppColors.warning;
      if (ratio < 0.9) return AppColors.danger;
      return AppColors.danger;
    }

    return Scaffold(
      appBar: SpendrAppBar(title: 'Spendr'),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budgets',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                formatMonth(currentMonth),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUDGET HEALTH',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight(500),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getBudgetHealth(totalSpent, user?.monthlyBudget ?? 0),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: getBudgetHealthColor(
                          totalSpent,
                          user?.monthlyBudget ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                        children: [
                          TextSpan(text: "You've saved "),
                          TextSpan(
                            text:
                                '\$${formatter.format(user?.monthlyBudget ?? 0)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' this month!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'TOTAL BUDGET',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight(500),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${formatter.format(user?.monthlyBudget ?? 0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(36, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'SPENT SO FAR',
                                  style: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight(500),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '\$${formatter.format(totalSpent)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 
                          user?.monthlyBudget == null ||
                              user!.monthlyBudget == 0
                          ? 0
                          : (totalSpent / user!.monthlyBudget).clamp(
                              0.0,
                              1.0,
                            ),
                          minHeight: 8,
                          backgroundColor: AppColors.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            totalSpent / (user?.monthlyBudget ?? 1) < 0.75
                                ? AppColors
                                      .primary // green
                                : totalSpent / (user?.monthlyBudget ?? 1) < 0.9
                                ? AppColors
                                      .warning // orange
                                : AppColors.danger, // red
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
