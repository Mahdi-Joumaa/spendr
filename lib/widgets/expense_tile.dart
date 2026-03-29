import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/theme.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseTile({Key? key, required this.expense}) : super(key: key);

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'health': return Icons.favorite;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[expense.categoryId] ?? AppColors.textSecondary;
    final icon = _getCategoryIcon(expense.categoryId);
    final formatter = NumberFormat('#,##0.00');
    final dateFormatter = DateFormat('MMM d, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [

          // category icon circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          // note and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.note.isEmpty ? expense.categoryId : expense.note,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  dateFormatter.format(expense.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // amount
          Text(
            '-\$${formatter.format(expense.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}