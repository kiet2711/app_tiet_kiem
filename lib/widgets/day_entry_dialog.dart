import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saving_day.dart';
import '../utils/formatters.dart';

class DayEntryDialog extends StatefulWidget {
  final SavingDay? initialDay;
  final Function(SavingDay) onSave;

  const DayEntryDialog({
    super.key,
    this.initialDay,
    required this.onSave,
  });

  @override
  State<DayEntryDialog> createState() => _DayEntryDialogState();
}

class _DayEntryDialogState extends State<DayEntryDialog> {
  late DateTime _selectedDate;
  late TextEditingController _actualController;
  late TextEditingController _projectedController;
  late TextEditingController _noteController;

  double _actualAmount = 0.0;
  double _projectedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDay?.date ?? DateTime.now();
    _actualAmount = widget.initialDay?.actualAmount ?? 0.0;
    _projectedAmount = widget.initialDay?.projectedAmount ?? 0.0;

    _actualController = TextEditingController(
      text: _actualAmount > 0 ? Formatters.formatNumber(_actualAmount) : '',
    );
    _projectedController = TextEditingController(
      text: _projectedAmount > 0 ? Formatters.formatNumber(_projectedAmount) : '',
    );
    _noteController = TextEditingController(
      text: widget.initialDay?.note ?? '',
    );
  }

  @override
  void dispose() {
    _actualController.dispose();
    _projectedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onActualChanged(String val) {
    setState(() {
      _actualAmount = Formatters.parseDouble(val);
    });
  }

  void _onProjectedChanged(String val) {
    setState(() {
      _projectedAmount = Formatters.parseDouble(val);
    });
  }

  void _addAmountToActual(double amount) {
    setState(() {
      _actualAmount += amount;
      _actualController.text = Formatters.formatNumber(_actualAmount);
    });
  }

  void _addAmountToProjected(double amount) {
    setState(() {
      _projectedAmount += amount;
      _projectedController.text = Formatters.formatNumber(_projectedAmount);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn ngày ghi chép',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    final newDay = SavingDay(
      id: widget.initialDay?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      actualAmount: _actualAmount,
      projectedAmount: _projectedAmount,
      note: _noteController.text.trim(),
    );
    widget.onSave(newDay);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDay != null;
    final totalDay = _actualAmount + _projectedAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF198754).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_calendar : Icons.add_circle_outline,
                          color: const Color(0xFF198754),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEditing ? 'Sửa bản ghi ngày' : 'Nhập tiền ngày mới',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Date Picker Button
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF198754)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày ghi nhận',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              Formatters.formatDateWithWeekday(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ô 1: ĐÃ TIẾT KIỆM ĐƯỢC
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
                            SizedBox(width: 6),
                            Text(
                              '1. Đã tiết kiệm được',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          Formatters.formatCurrency(_actualAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _actualController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onActualChanged,
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền đã cất (VNĐ)',
                        suffixText: '₫',
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick add chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickChip('+10k', () => _addAmountToActual(10000)),
                          _buildQuickChip('+20k', () => _addAmountToActual(20000)),
                          _buildQuickChip('+50k', () => _addAmountToActual(50000)),
                          _buildQuickChip('+100k', () => _addAmountToActual(100000)),
                          _buildQuickChip('+200k', () => _addAmountToActual(200000)),
                          _buildQuickChip('+500k', () => _addAmountToActual(500000)),
                          _buildClearChip(() {
                            setState(() {
                              _actualAmount = 0;
                              _actualController.clear();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Ô 2: CÓ THỂ SẼ TIẾT KIỆM ĐƯỢC
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb, size: 16, color: Color(0xFFF57F17)),
                            SizedBox(width: 6),
                            Text(
                              '2. Có thể sẽ tiết kiệm được',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          Formatters.formatCurrency(_projectedAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _projectedController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _onProjectedChanged,
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền dự kiến tiết kiệm (VNĐ)',
                        suffixText: '₫',
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick add chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickChip('+10k', () => _addAmountToProjected(10000), color: Colors.orange),
                          _buildQuickChip('+20k', () => _addAmountToProjected(20000), color: Colors.orange),
                          _buildQuickChip('+50k', () => _addAmountToProjected(50000), color: Colors.orange),
                          _buildQuickChip('+100k', () => _addAmountToProjected(100000), color: Colors.orange),
                          _buildQuickChip('+200k', () => _addAmountToProjected(200000), color: Colors.orange),
                          _buildQuickChip('+500k', () => _addAmountToProjected(500000), color: Colors.orange),
                          _buildClearChip(() {
                            setState(() {
                              _projectedAmount = 0;
                              _projectedController.clear();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Nút chuyển nhanh dự kiến sang đã tiết kiệm
              if (_projectedAmount > 0) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      _actualAmount += _projectedAmount;
                      _projectedAmount = 0;
                      _actualController.text = Formatters.formatNumber(_actualAmount);
                      _projectedController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã chuyển tiền dự kiến sang Đã tiết kiệm!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF198754).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF198754).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.published_with_changes_rounded, size: 18, color: Color(0xFF198754)),
                        const SizedBox(width: 8),
                        Text(
                          'Chuyển ${Formatters.formatCurrency(_projectedAmount)} sang Đã Tiết Kiệm',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF198754),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Ghi chú (Note)
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  hintText: 'Ví dụ: nhịn ăn vặt, tiền làm thêm...',
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Thống kê nhanh trong ngày
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tích lũy ngày này:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Formatters.formatCurrency(totalDay),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5132),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF198754),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Cập nhật' : 'Thêm vào bảng',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap, {Color color = const Color(0xFF198754)}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearChip(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Xóa',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
