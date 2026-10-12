import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/saving_day.dart';
import 'models/saving_goal.dart';
import 'services/storage_service.dart';
import 'widgets/goal_summary_card.dart';
import 'widgets/quick_saving_action_card.dart';
import 'widgets/compact_daily_list_view.dart';
import 'widgets/day_entry_dialog.dart';
import 'widgets/edit_goal_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SavingTrackerApp());
}

class SavingTrackerApp extends StatelessWidget {
  const SavingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sổ Tiết Kiệm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF198754),
          primary: const Color(0xFF198754),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F5132),
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      home: const SavingHomePage(),
    );
  }
}

class SavingHomePage extends StatefulWidget {
  const SavingHomePage({super.key});

  @override
  State<SavingHomePage> createState() => _SavingHomePageState();
}

class _SavingHomePageState extends State<SavingHomePage> {
  final StorageService _storageService = StorageService();

  SavingGoal _goal = SavingGoal(
    targetAmount: 1000000,
    title: 'Mục tiêu 1 Triệu',
  );

  List<SavingDay> _days = [];
  bool _isLoading = true;
  late SavingDay _activeDay;

  @override
  void initState() {
    super.initState();
    _activeDay = _createTodayEntry();
    _loadData();
  }

  SavingDay _createTodayEntry([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    return SavingDay(
      id: '${targetDate.year}-${targetDate.month}-${targetDate.day}',
      date: targetDate,
      actualAmount: 0,
      projectedAmount: 0,
    );
  }

  Future<void> _loadData() async {
    final loadedGoal = await _storageService.loadGoal();
    final loadedDays = await _storageService.loadDays();

    // Tìm xem đã có ngày hôm nay trong danh sách chưa
    final now = DateTime.now();
    SavingDay? todayFound;
    for (final day in loadedDays) {
      if (day.date.year == now.year && day.date.month == now.month && day.date.day == now.day) {
        todayFound = day;
        break;
      }
    }

    setState(() {
      _goal = loadedGoal;
      _days = loadedDays;
      _days.sort((a, b) => b.date.compareTo(a.date)); // Mới nhất lên đầu
      _activeDay = todayFound ?? _createTodayEntry();
      _isLoading = false;
    });
  }

  // TỔNG HIỆN TẠI (Thực tế đã tiết kiệm được)
  double get _totalActual {
    return _days.fold(0.0, (sum, day) => sum + day.actualAmount);
  }

  // TỔNG CÓ THỂ TIẾT KIỆM THÊM (Dự kiến)
  double get _totalProjectedAdditional {
    return _days.fold(0.0, (sum, day) => sum + day.projectedAmount);
  }

  Future<void> _saveGoal(SavingGoal newGoal) async {
    setState(() {
      _goal = newGoal;
    });
    await _storageService.saveGoal(newGoal);
  }

  Future<void> _updateActiveDay(SavingDay updated) async {
    setState(() {
      _activeDay = updated;
      final index = _days.indexWhere((d) => d.id == updated.id);
      if (index >= 0) {
        _days[index] = updated;
      } else {
        _days.add(updated);
      }
      _days.sort((a, b) => b.date.compareTo(a.date));
    });
    await _storageService.saveDays(_days);
  }

  Future<void> _transferDayProjectedToActual(SavingDay day) async {
    if (day.projectedAmount <= 0) return;
    final updated = day.convertProjectedToActual();
    await _updateActiveDay(updated);
  }

  Future<void> _transferAllProjectedToActual() async {
    final hasProjected = _days.any((d) => d.projectedAmount > 0);
    if (!hasProjected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có khoản tiền dự kiến nào cần chuyển')),
      );
      return;
    }
    setState(() {
      _days = _days.map((d) => d.convertProjectedToActual()).toList();
      final activeIndex = _days.indexWhere((d) => d.id == _activeDay.id);
      if (activeIndex >= 0) {
        _activeDay = _days[activeIndex];
      }
    });
    await _storageService.saveDays(_days);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chuyển tất cả tiền dự kiến sang Đã Tiết Kiệm!'),
          backgroundColor: Color(0xFF198754),
        ),
      );
    }
  }

  Future<void> _deleteDay(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ngày ghi chép này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _days.removeWhere((item) => item.id == id);
        if (_activeDay.id == id) {
          _activeDay = _createTodayEntry();
        }
      });
      await _storageService.saveDays(_days);
    }
  }

  Future<void> _pickDateForActiveDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activeDay.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn ngày muốn cộng / trừ tiền',
    );
    if (picked != null) {
      // Tìm xem ngày này đã có trong list chưa
      final existing = _days.firstWhere(
        (d) => d.date.year == picked.year && d.date.month == picked.month && d.date.day == picked.day,
        orElse: () => _createTodayEntry(picked),
      );
      setState(() {
        _activeDay = existing;
      });
    }
  }

  void _openEditGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => EditGoalDialog(
        currentGoal: _goal,
        onSave: _saveGoal,
      ),
    );
  }

  void _openEditDayDialog(SavingDay day) {
    showDialog(
      context: context,
      builder: (context) => DayEntryDialog(
        initialDay: day,
        onSave: _updateActiveDay,
      ),
    );
  }

  void _populateDemoData() async {
    final now = DateTime.now();
    final demoDays = [
      SavingDay(
        id: '${now.year}-${now.month}-${now.day}',
        date: now,
        actualAmount: 35000,
        projectedAmount: 15000,
        note: 'Bớt tiền cà phê',
      ),
      SavingDay(
        id: '${now.subtract(const Duration(days: 1)).year}-${now.subtract(const Duration(days: 1)).month}-${now.subtract(const Duration(days: 1)).day}',
        date: now.subtract(const Duration(days: 1)),
        actualAmount: 50000,
        projectedAmount: 20000,
      ),
      SavingDay(
        id: '${now.subtract(const Duration(days: 2)).year}-${now.subtract(const Duration(days: 2)).month}-${now.subtract(const Duration(days: 2)).day}',
        date: now.subtract(const Duration(days: 2)),
        actualAmount: 120000,
        projectedAmount: 0,
      ),
      SavingDay(
        id: '${now.subtract(const Duration(days: 3)).year}-${now.subtract(const Duration(days: 3)).month}-${now.subtract(const Duration(days: 3)).day}',
        date: now.subtract(const Duration(days: 3)),
        actualAmount: 80000,
        projectedAmount: 50000,
      ),
    ];

    setState(() {
      _days = demoDays;
      _activeDay = demoDays.first;
    });
    await _storageService.saveDays(_days);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo dữ liệu mẫu')),
      );
    }
  }

  void _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại dữ liệu'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả lịch sử không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa hết', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _days.clear();
        _activeDay = _createTodayEntry();
      });
      await _storageService.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF198754)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.savings_rounded, color: Color(0xFF198754), size: 24),
            SizedBox(width: 8),
            Text(
              'Sổ Tiết Kiệm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F5132),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F5132)),
            onSelected: (val) {
              if (val == 'goal') _openEditGoalDialog();
              if (val == 'transferAll') _transferAllProjectedToActual();
              if (val == 'demo') _populateDemoData();
              if (val == 'clear') _clearAllData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'goal',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Đổi số tiền mục tiêu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'transferAll',
                child: Row(
                  children: [
                    Icon(Icons.published_with_changes_rounded, size: 18, color: Color(0xFF198754)),
                    SizedBox(width: 8),
                    Text('Chuyển tất cả dự kiến sang đã có'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'demo',
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 18, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Tạo dữ liệu mẫu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa tất cả'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Thẻ tiến trình mục tiêu gọn nhẹ
              GoalSummaryCard(
                goal: _goal,
                totalActual: _totalActual,
                totalProjectedAdditional: _totalProjectedAdditional,
                onEditGoal: _openEditGoalDialog,
              ),

              // 2. KHUNG NHẬP NHANH TỰ TÍNH TỔNG (+5k, +10k, -5k, -10k, tùy ý)
              QuickSavingActionCard(
                activeDay: _activeDay,
                onUpdateDay: _updateActiveDay,
                onSelectOtherDate: _pickDateForActiveDay,
              ),

              // 3. Tiêu đề danh sách
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lịch sử theo ngày',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5132),
                      ),
                    ),
                    Text(
                      '${_days.length} ngày',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 4. DANH SÁCH GỌN GÀNG (100% VỪA MÀN HÌNH, KHÔNG KÉO NGANG)
              CompactDailyListView(
                days: _days,
                activeDayId: _activeDay.id,
                onSelectActiveDay: (selected) {
                  setState(() => _activeDay = selected);
                },
                onTransferProjected: _transferDayProjectedToActual,
                onEdit: _openEditDayDialog,
                onDelete: _deleteDay,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
