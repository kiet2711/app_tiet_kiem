import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saving_goal.dart';
import '../utils/formatters.dart';

class EditGoalDialog extends StatefulWidget {
  final SavingGoal currentGoal;
  final Function(SavingGoal) onSave;

  const EditGoalDialog({
    super.key,
    required this.currentGoal,
    required this.onSave,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late double _amount;

  final List<double> _presetGoals = [
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
    20000000,
    50000000,
  ];

  @override
  void initState() {
    super.initState();
    _amount = widget.currentGoal.targetAmount;
    _titleController = TextEditingController(text: widget.currentGoal.title);
    _amountController = TextEditingController(
      text: Formatters.formatNumber(_amount),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    setState(() {
      _amount = Formatters.parseDouble(val);
    });
  }

  void _selectPreset(double preset) {
    setState(() {
      _amount = preset;
      _amountController.text = Formatters.formatNumber(preset);
      if (_titleController.text.isEmpty ||
          _titleController.text.startsWith('Mục tiêu')) {
        _titleController.text = 'Mục tiêu ${Formatters.formatNumber(preset)}₫';
      }
    });
  }

  void _submit() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền mục tiêu lớn hơn 0')),
      );
      return;
    }

    final newGoal = widget.currentGoal.copyWith(
      targetAmount: _amount,
      title: _titleController.text.trim().isEmpty
          ? 'Mục tiêu tiết kiệm'
          : _titleController.text.trim(),
    );
    widget.onSave(newGoal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF198754).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Color(0xFF198754),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Đặt mục tiêu tiết kiệm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Tên mục tiêu
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tên mục tiêu',
                hintText: 'Ví dụ: Mục tiêu 1 triệu, Mua laptop...',
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Số tiền mục tiêu
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _onAmountChanged,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F5132),
              ),
              decoration: InputDecoration(
                labelText: 'Số tiền mục tiêu (VNĐ)',
                suffixText: '₫',
                prefixIcon: const Icon(Icons.attach_money, size: 20),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Gợi ý nhanh các mốc phổ biến
            const Text(
              'Gợi ý nhanh:',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presetGoals.map((val) {
                final isSelected = _amount == val;
                final label = val >= 1000000
                    ? '${(val / 1000000).toStringAsFixed(val % 1000000 == 0 ? 0 : 1)} triệu'
                    : '${(val / 1000).round()}k';
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: const Color(0xFF198754),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (_) => _selectPreset(val),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // Buttons
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lưu mục tiêu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
