import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/saving_day.dart';
import 'models/saving_goal.dart';
import 'services/storage_service.dart';
import 'utils/formatters.dart';
import 'widgets/goal_summary_card.dart';
import 'widgets/daily_table_view.dart';
import 'widgets/daily_card_list_view.dart';
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
      title: 'Sổ Tiết Kiệm - Saving Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF198754),
          primary: const Color(0xFF198754),
          secondary: const Color(0xFF0D6EFD),
          tertiary: const Color(0xFFF57F17),
          surface: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F5132),
          elevation: 0,
          centerTitle: false,
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
  bool _isTableView = true; // Chuyển đổi giữa chế độ Bảng và Thẻ
  bool _sortAscending = true; // Sắp xếp theo ngày

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedGoal = await _storageService.loadGoal();
    final loadedDays = await _storageService.loadDays();

    setState(() {
      _goal = loadedGoal;
      _days = loadedDays;
      _sortDays();
      _isLoading = false;
    });
  }

  void _sortDays() {
    _days.sort((a, b) => _sortAscending
        ? a.date.compareTo(b.date)
        : b.date.compareTo(a.date));
  }

  // TỔNG HIỆN TẠI (Thực tế đã tiết kiệm được)
  double get _totalActual {
    return _days.fold(0.0, (sum, day) => sum + day.actualAmount);
  }

  // TỔNG CÓ THỂ TIẾT KIỆM THÊM (Dự kiến)
  double get _totalProjectedAdditional {
    return _days.fold(0.0, (sum, day) => sum + day.projectedAmount);
  }

  // TỔNG DỰ KIẾN (Tiềm năng = Đã có + Có thể tiết kiệm)
  double get _totalPotential {
    return _totalActual + _totalProjectedAdditional;
  }

  Future<void> _saveGoal(SavingGoal newGoal) async {
    setState(() {
      _goal = newGoal;
    });
    await _storageService.saveGoal(newGoal);
  }

  Future<void> _addOrUpdateDay(SavingDay day) async {
    setState(() {
      final index = _days.indexWhere((item) => item.id == day.id);
      if (index >= 0) {
        _days[index] = day;
      } else {
        _days.add(day);
      }
      _sortDays();
    });
    await _storageService.saveDays(_days);
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
      });
      await _storageService.saveDays(_days);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ngày ghi chép'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _transferDayProjectedToActual(SavingDay day) async {
    if (day.projectedAmount <= 0) return;
    final transferred = day.projectedAmount;
    final updated = day.convertProjectedToActual();
    await _addOrUpdateDay(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã chuyển ${Formatters.formatCurrency(transferred)} sang tiền Đã Tiết Kiệm!',
          ),
          backgroundColor: const Color(0xFF198754),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _transferAllProjectedToActual() async {
    final hasProjected = _days.any((d) => d.projectedAmount > 0);
    if (!hasProjected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có khoản tiền dự kiến nào cần chuyển')),
      );
      return;
    }
    final totalTransferred = _totalProjectedAdditional;
    setState(() {
      _days = _days.map((d) => d.convertProjectedToActual()).toList();
    });
    await _storageService.saveDays(_days);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã chuyển tất cả ${Formatters.formatCurrency(totalTransferred)} sang Đã Tiết Kiệm!',
          ),
          backgroundColor: const Color(0xFF198754),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openAddDayDialog() {
    // Mặc định chọn ngày hôm nay hoặc ngày tiếp theo
    DateTime defaultDate = DateTime.now();
    if (_days.isNotEmpty) {
      final lastDate = _days.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
      if (lastDate.isBefore(DateTime.now())) {
        defaultDate = DateTime.now();
      } else {
        defaultDate = lastDate.add(const Duration(days: 1));
      }
    }

    showDialog(
      context: context,
      builder: (context) => DayEntryDialog(
        initialDay: SavingDay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: defaultDate,
          actualAmount: 0,
          projectedAmount: 0,
        ),
        onSave: _addOrUpdateDay,
      ),
    );
  }

  void _openEditDayDialog(SavingDay day) {
    showDialog(
      context: context,
      builder: (context) => DayEntryDialog(
        initialDay: day,
        onSave: _addOrUpdateDay,
      ),
    );
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

  void _populateDemoData() async {
    final now = DateTime.now();
    final demoDays = [
      SavingDay(
        id: '1',
        date: now.subtract(const Duration(days: 4)),
        actualAmount: 150000,
        projectedAmount: 50000,
        note: 'Tiền thưởng tuần',
      ),
      SavingDay(
        id: '2',
        date: now.subtract(const Duration(days: 3)),
        actualAmount: 80000,
        projectedAmount: 20000,
        note: 'Bớt tiền ăn ngoài',
      ),
      SavingDay(
        id: '3',
        date: now.subtract(const Duration(days: 2)),
        actualAmount: 200000,
        projectedAmount: 0,
        note: 'Thu nhập làm thêm',
      ),
      SavingDay(
        id: '4',
        date: now.subtract(const Duration(days: 1)),
        actualAmount: 120000,
        projectedAmount: 30000,
        note: 'Nuôi heo đất',
      ),
      SavingDay(
        id: '5',
        date: now,
        actualAmount: 100000,
        projectedAmount: 150000,
        note: 'Dự kiến bán đồ cũ',
      ),
    ];

    setState(() {
      _days = demoDays;
      _sortDays();
    });
    await _storageService.saveDays(_days);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo 5 ngày dữ liệu mẫu thành công!')),
      );
    }
  }

  void _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt lại'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ dữ liệu bảng tính?'),
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
      });
      await _storageService.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt lại dữ liệu')),
        );
      }
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF198754).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Color(0xFF198754), size: 24),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sổ Tiết Kiệm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F5132),
                  ),
                ),
                Text(
                  'Theo dõi mục tiêu & bảng ngày',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Nút đổi chế độ Bảng / Danh sách thẻ
          IconButton(
            tooltip: _isTableView ? 'Chuyển sang chế độ Thẻ' : 'Chuyển sang Bảng tính',
            icon: Icon(
              _isTableView ? Icons.view_agenda_outlined : Icons.table_chart_outlined,
              color: const Color(0xFF0F5132),
            ),
            onPressed: () {
              setState(() {
                _isTableView = !_isTableView;
              });
            },
          ),
          // Popup menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F5132)),
            onSelected: (val) {
              if (val == 'demo') {
                _populateDemoData();
              } else if (val == 'transferAll') {
                _transferAllProjectedToActual();
              } else if (val == 'clear') {
                _clearAllData();
              } else if (val == 'goal') {
                _openEditGoalDialog();
              } else if (val == 'sort') {
                setState(() {
                  _sortAscending = !_sortAscending;
                  _sortDays();
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'goal',
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Đổi mục tiêu tiết kiệm'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 18, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(_sortAscending ? 'Sắp xếp: Ngày mới trước' : 'Sắp xếp: Ngày cũ trước'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'transferAll',
                child: const Row(
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
                    Text('Xóa toàn bộ bảng'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thẻ tổng quan mục tiêu & 2 tổng hiện tại / dự kiến
              GoalSummaryCard(
                goal: _goal,
                totalActual: _totalActual,
                totalProjectedAdditional: _totalProjectedAdditional,
                onEditGoal: _openEditGoalDialog,
              ),

              // Thanh tiêu đề Bảng ngày & chuyển đổi giao diện
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Bảng tính theo ngày',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F5132),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF198754).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_days.length} ngày',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF198754),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Nút thêm nhanh
                        TextButton.icon(
                          onPressed: _openAddDayDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Thêm ngày'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF198754),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bảng tính (Table View) hoặc Thẻ (Card View)
              if (_isTableView)
                DailyTableView(
                  days: _days,
                  onEdit: _openEditDayDialog,
                  onDelete: _deleteDay,
                  onUpdateQuick: _addOrUpdateDay,
                  onTransferProjected: _transferDayProjectedToActual,
                )
              else
                DailyCardListView(
                  days: _days,
                  onEdit: _openEditDayDialog,
                  onDelete: _deleteDay,
                  onTransferProjected: _transferDayProjectedToActual,
                ),

              // Bảng tóm tắt thông tin chi tiết dưới chân trang
              if (_days.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số ngày đã ghi nhận:',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          Text(
                            '${_days.length} ngày',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Color(0xFF198754)),
                              SizedBox(width: 4),
                              Text(
                                'Tổng Đã Tiết Kiệm (Hiện tại):',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                          Text(
                            Formatters.formatCurrency(_totalActual),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF198754),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb, size: 14, color: Color(0xFFE65100)),
                              SizedBox(width: 4),
                              Text(
                                'Có thể tiết kiệm thêm:',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                          Text(
                            Formatters.formatCurrency(_totalProjectedAdditional),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TỔNG DỰ KIẾN TÍCH LŨY:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5132),
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(_totalPotential),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F5132),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDayDialog,
        backgroundColor: const Color(0xFF198754),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Nhập ngày mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
