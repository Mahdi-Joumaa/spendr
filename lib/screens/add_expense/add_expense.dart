import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/expense_service.dart';
import '../../utils/theme.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  String _amountString = '0';
  String _selectedCategory = 'food';
  String _note = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final _noteController = TextEditingController();
  final _expenseService = ExpenseService();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'transport', 'label': 'Transport', 'icon': Icons.directions_car},
    {'id': 'shopping', 'label': 'Shopping', 'icon': Icons.shopping_bag},
    {'id': 'health', 'label': 'Health', 'icon': Icons.health_and_safety},
    {'id': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'del') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (value == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = value;
        } else {
          if (_amountString.contains('.')) {
            final parts = _amountString.split('.');
            if (parts[1].length < 2) {
              _amountString += value;
            }
          } else {
            _amountString += value;
          }
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountString) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid == null) return;

      final month =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';

      final expense = ExpenseModel(
        expenseId: const Uuid().v4(),
        amount: amount,
        categoryId: _selectedCategory,
        note: _noteController.text.trim(),
        date: _selectedDate,
        month: month,
        createdAt: DateTime.now(),
      );

      await _expenseService.addExpense(uid, expense);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('How to use', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '1. Enter the amount using the numpad\n'
          '2. Select a category\n'
          '3. Add a note (optional)\n'
          '4. Pick the date\n'
          '5. Tap Save Expense',
          style: TextStyle(color: AppColors.textSecondary, height: 1.8),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP BAR ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Add Expense',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Row(
                    children: [
                      Text('Spendr', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showHelp,
                        child: Icon(Icons.help_outline, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── AMOUNT DISPLAY ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    'TRANSACTION AMOUNT',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('\$', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(
                        _amountString,
                        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE MIDDLE ────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('REQUIRED', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.2)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat['id'];
                          final color = AppColors.categoryColors[cat['id']] ?? AppColors.textSecondary;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat['id']),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withOpacity(0.15) : AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? color : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(cat['icon'] as IconData, color: isSelected ? color : AppColors.textSecondary, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat['label'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? color : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _noteController,
                      onChanged: (val) => _note = val,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        suffixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedDate.day == DateTime.now().day ? 'Today' : DateFormat('EEEE').format(_selectedDate),
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── NUMPAD ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ...[['1','2','3'], ['4','5','6'], ['7','8','9']].map((row) => Row(
                    children: row.map((num) => Expanded(
                      child: GestureDetector(
                        onTap: () => _onNumpadTap(num),
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(num, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        ),
                      ),
                    )).toList(),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onNumpadTap('.'),
                          child: Container(height: 60, alignment: Alignment.center,
                            child: Text('.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onNumpadTap('0'),
                          child: Container(height: 60, alignment: Alignment.center,
                            child: Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onNumpadTap('del'),
                          child: Container(height: 60, alignment: Alignment.center,
                            child: Icon(Icons.backspace_outlined, color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── SAVE BUTTON ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}