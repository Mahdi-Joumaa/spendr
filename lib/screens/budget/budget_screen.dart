import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<String> _visibleCategories = ['food', 'transport', 'shopping', 'health', 'other'];

  // updates ONLY the category limit — does not touch monthlyBudget
  Future<void> _updateCategoryLimit(String uid, String categoryId, double newLimit) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(categoryId)
        .update({'budgetLimit': newLimit});
  }

  // deletes ONLY expenses for one category — does not touch limits or monthlyBudget
  Future<void> _deleteCategoryExpenses(String uid, String categoryId) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // deletes ALL expenses — does not touch limits or monthlyBudget
  Future<void> _deleteAllExpenses(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _showEditDialog(BuildContext context, String categoryId, String categoryName, double currentLimit) {
    final controller = TextEditingController(text: currentLimit.toStringAsFixed(0));
    final uid = ref.read(authStateProvider).value?.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $categoryName Budget', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Enter new limit', prefixText: '\$ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0 && uid != null) {
                await _updateCategoryLimit(uid, categoryId, val);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String categoryId, String categoryName) {
    final uid = ref.read(authStateProvider).value?.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete $categoryName Expenses', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will permanently delete all expenses in $categoryName. Your budget limit will not change.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              if (uid != null) await _deleteCategoryExpenses(uid, categoryId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showResetAllDialog(BuildContext context) {
    final uid = ref.read(authStateProvider).value?.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset All Expenses', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will permanently delete all your expenses. Your budget limits and monthly budget will not change.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              if (uid != null) await _deleteAllExpenses(uid);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'health': return Icons.favorite;
      case 'other': return Icons.more_horiz;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = ref.watch(totalSpentProvider);
    final budgetsAsync = ref.watch(budgetsProvider);
    final spentByCategory = ref.watch(spentByCategoryProvider);
    final user = ref.watch(currentUserProvider).value;
    final formatter = NumberFormat('#,##0');

    final double totalBudget = user?.monthlyBudget ?? 0.0;
    final double remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);
    final bool isOverBudget = totalSpent > totalBudget && totalBudget > 0;

    return Scaffold(
      appBar: const SpendrAppBar(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TITLE + RESET ALL ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Budgets',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => _showResetAllDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Reset All',
                        style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── HEALTH CARD ──────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BUDGET HEALTH', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(
                      totalBudget == 0
                          ? 'No Budget Set'
                          : isOverBudget
                              ? 'Over Budget'
                              : totalSpent / totalBudget < 0.5
                                  ? 'Excellent'
                                  : totalSpent / totalBudget < 0.75
                                      ? 'Good'
                                      : 'Watch Out',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: totalBudget == 0
                            ? AppColors.textSecondary
                            : isOverBudget
                                ? AppColors.danger
                                : totalSpent / totalBudget < 0.75
                                    ? AppColors.primary
                                    : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(text: isOverBudget ? "You've overspent " : "You've saved "),
                          TextSpan(
                            text: '\$${formatter.format(isOverBudget ? totalSpent - totalBudget : remaining)}',
                            style: TextStyle(color: isOverBudget ? AppColors.danger : AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: isOverBudget ? ' this month. Take a breather!' : ' this month. Keep it up!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL BUDGET', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.2)),
                            Text('\$${formatter.format(totalBudget)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SPENT SO FAR', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.2)),
                            Text('\$${formatter.format(totalSpent)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isOverBudget ? AppColors.danger : AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                    if (totalBudget > 0) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppColors.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? AppColors.danger : totalSpent / totalBudget < 0.75 ? AppColors.primary : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── CATEGORIES TITLE ─────────────────
              Text('Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),

              // ── CATEGORY LIST ────────────────────
              budgetsAsync.when(
                data: (budgetList) {
                  final filtered = budgetList
                      .where((b) => _visibleCategories.contains(b.categoryId))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('No categories found', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }

                  return Column(
                    children: filtered.map((budget) {
                      final spent = spentByCategory[budget.categoryId] ?? 0.0;
                      final bool isCategoryOver = budget.budgetLimit > 0 && spent > budget.budgetLimit;
                      final double pct = budget.budgetLimit == 0.0
                          ? 0.0
                          : (spent / budget.budgetLimit).clamp(0.0, 1.0);
                      final Color ringColor = isCategoryOver
                          ? AppColors.danger
                          : pct < 0.7
                              ? AppColors.primary
                              : AppColors.warning;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [

                            // ring
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(56, 56),
                                    painter: _RingPainter(
                                      progress: pct,
                                      color: ringColor,
                                      backgroundColor: AppColors.surface,
                                    ),
                                  ),
                                  Text(
                                    '${(pct * 100).toInt()}%',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ringColor),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            // info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getCategoryIcon(budget.categoryId), size: 14, color: ringColor),
                                      const SizedBox(width: 6),
                                      Text(budget.name, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '\$${formatter.format(spent)}',
                                          style: TextStyle(
                                            color: isCategoryOver ? AppColors.danger : AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / \$${formatter.format(budget.budgetLimit)}',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // edit button
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                              onPressed: () => _showEditDialog(context, budget.categoryId, budget.name, budget.budgetLimit),
                            ),

                            // delete expenses button
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                              onPressed: () => _showDeleteDialog(context, budget.categoryId, budget.name),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading budgets', style: TextStyle(color: AppColors.danger)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({required this.progress, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = backgroundColor);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}