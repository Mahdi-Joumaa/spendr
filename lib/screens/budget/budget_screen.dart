import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendr/providers/auth_provider.dart';
import 'package:spendr/providers/budget_provider.dart';
import 'package:spendr/providers/expense_provider.dart';
import 'package:spendr/utils/theme.dart';
import 'package:spendr/widgets/spendr_app_bar.dart';
import 'package:spendr/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {

  String formatMonth(String month) {
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return '${_monthName(int.parse(parts[1]))} ${parts[0]}'.toUpperCase();
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

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

  // show edit budget dialog
  void _showEditDialog(BuildContext context, String categoryId, String categoryName, double currentLimit) {
    final controller = TextEditingController(text: currentLimit.toStringAsFixed(0));
    final uid = ref.read(authStateProvider).value?.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Edit $categoryName Budget',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter new limit',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final newLimit = double.tryParse(controller.text);
              if (newLimit != null && newLimit > 0 && uid != null) {
                final budgetService = ref.read(budgetServiceProvider);
                await budgetService.updateBudgetLimit(uid, categoryId, newLimit);
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = ref.watch(totalSpentProvider);
    final budgets = ref.watch(budgetsProvider);
    final spentByCategory = ref.watch(spentByCategoryProvider);
    final user = ref.watch(currentUserProvider).value;
    final currentMonth = ref.watch(currentMonthProvider);
    final formatter = NumberFormat('#,##0');

    return Scaffold(
      appBar: SpendrAppBar(),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TITLE ────────────────────────────
              Text(
                'Monthly Budgets',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                formatMonth(currentMonth),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 24),

              // ── HEALTH CARD ──────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUDGET HEALTH',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getBudgetHealth(totalSpent, user?.monthlyBudget ?? 0),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: getBudgetHealthColor(totalSpent, user?.monthlyBudget ?? 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: "You've saved "),
                          TextSpan(
                            text: '\$${formatter.format((user?.monthlyBudget ?? 0) - totalSpent)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' more than last month. Keep it up!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL BUDGET',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${formatter.format(user?.monthlyBudget ?? 0)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPENT SO FAR',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${formatter.format(totalSpent)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: user?.monthlyBudget == null || user!.monthlyBudget == 0
                            ? 0
                            : (totalSpent / user!.monthlyBudget).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          totalSpent / (user?.monthlyBudget ?? 1) < 0.75
                              ? AppColors.primary
                              : totalSpent / (user?.monthlyBudget ?? 1) < 0.9
                                  ? AppColors.warning
                                  : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── CATEGORIES HEADER ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      '+ New Category',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── CATEGORY LIST ────────────────────
              budgets.when(
                data: (budgetList) {
                  if (budgetList.isEmpty) {
                    return Center(
                      child: Text(
                        'No budgets found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return Column(
                    children: budgetList.map((budget) {
                      final spent = spentByCategory[budget.categoryId] ?? 0.0;
                      final percentage = budget.budgetLimit == 0
                          ? 0.0
                          : spent / budget.budgetLimit;
                      final isOver = percentage > 1.0;
                      final color = percentage < 0.7
                          ? AppColors.primary
                          : percentage < 0.9
                              ? AppColors.warning
                              : AppColors.danger;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [

                            // budget ring
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(64, 64),
                                    painter: _RingPainter(
                                      progress: percentage.clamp(0.0, 1.0),
                                      color: color,
                                      backgroundColor: AppColors.surface,
                                    ),
                                  ),
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // category info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(budget.categoryId),
                                        size: 16,
                                        color: color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        budget.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '\$${formatter.format(spent)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isOver
                                                ? AppColors.danger
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / \$${formatter.format(budget.budgetLimit)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // edit button
                            GestureDetector(
                              onTap: () => _showEditDialog(
                                context,
                                budget.categoryId,
                                budget.name,
                                budget.budgetLimit,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(
                  'Error loading budgets',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'bills': return Icons.receipt;
      case 'entertainment': return Icons.movie;
      case 'health': return Icons.favorite;
      default: return Icons.more_horiz;
    }
  }
}

// custom ring painter
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const strokeWidth = 6.0;

    // background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // progress ring
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}