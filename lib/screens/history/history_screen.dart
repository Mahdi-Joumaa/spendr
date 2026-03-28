import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../services/expense_service.dart';
import '../../utils/theme.dart';
import '../../widgets/spendr_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expense_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  late String _selectedMonth;
  // Changed from late to nullable to prevent initialization errors
  Stream<List<ExpenseModel>>? _monthStream;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Initialize immediately instead of waiting for post-frame callback
    _updateStream();
  }

  void _updateStream() {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    setState(() {
      _monthStream = ExpenseService().getExpensesByMonth(uid, _selectedMonth);
    });
  }

  String _formatMonthDisplay(String month) {
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(date);
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    final current = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _selectedMonth == current;
  }

  void _changeMonth(int direction) {
    final parts = _selectedMonth.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);
    month += direction;
    if (month > 12) {
      month = 1;
      year++;
    }
    if (month < 1) {
      month = 12;
      year--;
    }
    setState(() {
      _selectedMonth = '$year-${month.toString().padLeft(2, '0')}';
    });
    _updateStream();
  }

  Future<void> _pickMonth() async {
    final parts = _selectedMonth.split('-');
    final initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(now.year, now.month),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
      _updateStream();
    }
  }

  Map<String, List<ExpenseModel>> _groupByDate(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};
    for (final e in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return grouped;
  }

  String _getDateLabel(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MMMM d').format(date);
  }

  MapEntry<String, double>? _getPeakDay(List<ExpenseModel> expenses) {
    final Map<String, double> dailyTotals = {};
    for (final e in expenses) {
      final key = DateFormat('yyyy-MM-dd').format(e.date);
      dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
    }
    if (dailyTotals.isEmpty) return null;
    return dailyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  List<BarChartGroupData> _buildBarGroups(List<ExpenseModel> expenses) {
    final Map<int, double> dailyTotals = {};
    for (final e in expenses) {
      dailyTotals[e.date.day] = (dailyTotals[e.date.day] ?? 0) + e.amount;
    }
    final peakDay = _getPeakDay(expenses);
    final peakDayNumber = peakDay != null
        ? DateTime.parse(peakDay.key).day
        : -1;
    final parts = _selectedMonth.split('-');
    final daysInMonth = DateUtils.getDaysInMonth(
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final amount = dailyTotals[day] ?? 0;
      final isPeak = day == peakDayNumber;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: isPeak ? AppColors.danger : AppColors.surface,
            width: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    final formatterShort = NumberFormat('#,##0');

    return Scaffold(
      appBar: const SpendrAppBar(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _monthStream,
        builder: (context, snapshot) {
          // Check for null stream or connection waiting
          if (_monthStream == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history',
                style: TextStyle(color: AppColors.danger),
              ),
            );
          }

          final monthExpenses = snapshot.data ?? [];

          final filtered = _searchQuery.isEmpty
              ? monthExpenses
              : monthExpenses
                    .where(
                      (e) =>
                          e.note.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          e.categoryId.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

          final grouped = _groupByDate(filtered);
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          final totalOutflow = monthExpenses.fold(
            0.0,
            (sum, e) => sum + e.amount,
          );
          final daysWithExpenses = monthExpenses
              .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
              .toSet()
              .length;
          final dailyAverage = daysWithExpenses == 0
              ? 0.0
              : totalOutflow / daysWithExpenses;

          final peakDay = _getPeakDay(monthExpenses);
          final barGroups = _buildBarGroups(monthExpenses);

          final maxY = monthExpenses.isEmpty
              ? 100.0
              : monthExpenses
                        .fold(<String, double>{}, (map, e) {
                          final key = DateFormat('yyyy-MM-dd').format(e.date);
                          map[key] = (map[key] ?? 0) + e.amount;
                          return map;
                        })
                        .values
                        .reduce((a, b) => a > b ? a : b) *
                    1.2;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── MONTH SELECTOR ───────────────────
              Text(
                'VIEWING ACTIVITY',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Month Display (Left)
                  GestureDetector(
                    onTap: _pickMonth,
                    child: Row(
                      children: [
                        Text(
                          _formatMonthDisplay(_selectedMonth),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  // Navigation Arrows (Right - Grouped Together)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Back Arrow
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                          color: AppColors.textPrimary,
                          visualDensity: VisualDensity.compact,
                        ),
                        // Vertical Divider Line
                        Container(
                          height: 20,
                          width: 1,
                          color: AppColors.textSecondary.withOpacity(0.2),
                        ),
                        // Forward Arrow
                        IconButton(
                          onPressed: _isCurrentMonth()
                              ? null
                              : () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                          color: _isCurrentMonth()
                              ? AppColors.textSecondary.withOpacity(0.3)
                              : AppColors.textPrimary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── SEARCH BAR ───────────────────────
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search transactions, categories...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── BAR CHART CARD ───────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spending\nPattern',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daily trend for the\ncurrent month',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (peakDay != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PEAK DAY',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMMM d ·',
                                ).format(DateTime.parse(peakDay.key)),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${formatter.format(peakDay.value)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: monthExpenses.isEmpty
                          ? Center(
                              child: Text(
                                'No data for this month',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : BarChart(
                              BarChartData(
                                barGroups: barGroups,
                                maxY: maxY,
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final day = value.toInt();
                                        if (day == 1 ||
                                            day == 10 ||
                                            day == 20 ||
                                            day == 31) {
                                          final parts = _selectedMonth.split(
                                            '-',
                                          );
                                          final date = DateTime(
                                            int.parse(parts[0]),
                                            int.parse(parts[1]),
                                            day,
                                          );
                                          return Text(
                                            DateFormat(
                                              'MMM dd',
                                            ).format(date).toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                barTouchData: BarTouchData(enabled: false),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── STATS CARD ───────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Outflow',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '\$${formatterShort.format(totalOutflow.truncate())}',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                '.${(totalOutflow % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Average',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${formatter.format(dailyAverage)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── GROUPED TRANSACTIONS ─────────────
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      monthExpenses.isEmpty
                          ? 'No transactions this month'
                          : 'No results found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...sortedKeys.map((dateKey) {
                  final dayExpenses = grouped[dateKey]!;
                  final dayTotal = dayExpenses.fold(
                    0.0,
                    (sum, e) => sum + e.amount,
                  );
                  final label = _getDateLabel(dateKey);
                  final isPeakDay = peakDay?.key == dateKey;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPeakDay
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '\$${formatter.format(dayTotal)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isPeakDay
                                    ? AppColors.danger
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...dayExpenses.map(
                        (expense) => ExpenseTile(expense: expense),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
