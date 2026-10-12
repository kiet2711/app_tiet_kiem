import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saving_day.dart';
import '../utils/formatters.dart';

class QuickSavingActionCard extends StatefulWidget {
  final SavingDay activeDay;
  final Function(SavingDay) onUpdateDay;
  final VoidCallback onSelectOtherDate;

  const QuickSavingActionCard({
    super.key,
    required this.activeDay,
    required this.onUpdateDay,
    required this.onSelectOtherDate,
  });

  @override
  State<QuickSavingActionCard> createState() => _QuickSavingActionCardState();
}

class _QuickSavingActionCardState extends State<QuickSavingActionCard> {
  // false = đang thao tác trên "Đã tiết kiệm", true = "Có thể tiết kiệm"
  bool _isProjectedMode = false;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _addAmount(double amount) {
    if (amount <= 0) return;
    SavingDay updated;
    if (_isProjectedMode) {
      updated = widget.activeDay.addProjected(amount);
    } else {
      updated = widget.activeDay.addActual(amount);
    }
    widget.onUpdateDay(updated);
    _showFeedback('+${Formatters.formatNumber(amount)}₫');
  }

  void _subtractAmount(double amount) {
    if (amount <= 0) return;
    SavingDay updated;
    if (_isProjectedMode) {
      if (widget.activeDay.projectedAmount == 0) return;
      updated = widget.activeDay.subtractProjected(amount);
    } else {
      if (widget.activeDay.actualAmount == 0) return;
      updated = widget.activeDay.subtractActual(amount);
    }
    widget.onUpdateDay(updated);
    _showFeedback('-${Formatters.formatNumber(amount)}₫', isNegative: true);
  }

  void _applyCustom(bool isAdd) {
    final text = _customAmountController.text.trim();
    final amount = Formatters.parseDouble(text);
    if (amount <= 0) return;

    if (isAdd) {
      _addAmount(amount);
    } else {
      _subtractAmount(amount);
    }
    _customAmountController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showFeedback(String message, {bool isNegative = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isNegative ? Colors.orange.shade800 : const Color(0xFF198754),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
        margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.activeDay;
    final currentAmount = _isProjectedMode ? day.projectedAmount : day.actualAmount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dòng ngày + nút đổi ngày
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 20, color: Color(0xFFF57F17)),
                    const SizedBox(width: 6),
                    Text(
                      'Nhập nhanh: ${Formatters.formatDateWithWeekday(day.date)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: widget.onSelectOtherDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                        SizedBox(width: 4),
                        Text(
                          'Đổi ngày',
                          style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2 Tab chọn mục: [ ĐÃ TIẾT KIỆM ] vs [ CÓ THỂ TIẾT KIỆM ]
            Row(
              children: [
                // Tab 1: Đã tiết kiệm
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isProjectedMode = false),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: !_isProjectedMode ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: !_isProjectedMode ? const Color(0xFF198754) : Colors.grey.shade200,
                          width: !_isProjectedMode ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: !_isProjectedMode ? const Color(0xFF198754) : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ĐÃ TIẾT KIỆM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: !_isProjectedMode ? const Color(0xFF198754) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(day.actualAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: !_isProjectedMode ? const Color(0xFF0F5132) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tab 2: Dự kiến
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isProjectedMode = true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _isProjectedMode ? const Color(0xFFFFF8E1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isProjectedMode ? const Color(0xFFF57F17) : Colors.grey.shade200,
                          width: _isProjectedMode ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                size: 14,
                                color: _isProjectedMode ? const Color(0xFFE65100) : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'CÓ THỂ TIẾT KIỆM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isProjectedMode ? const Color(0xFFE65100) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(day.projectedAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isProjectedMode ? const Color(0xFFE65100) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nút chuyển nhanh nếu có tiền dự kiến
            if (_isProjectedMode && day.projectedAmount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    final amount = day.projectedAmount;
                    widget.onUpdateDay(day.convertProjectedToActual());
                    _showFeedback('Đã chuyển ${Formatters.formatNumber(amount)}₫ sang Đã tiết kiệm!');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF198754),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Chuyển ${Formatters.formatCurrency(day.projectedAmount)} sang ĐÃ CÓ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // NÚT CỘNG NHANH (+5k, +10k, +20k, +50k, +100k)
            Row(
              children: [
                const Text(
                  'Cộng:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF198754)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickBtn('+5k', () => _addAmount(5000), color: const Color(0xFF198754)),
                        _buildQuickBtn('+10k', () => _addAmount(10000), color: const Color(0xFF198754)),
                        _buildQuickBtn('+20k', () => _addAmount(20000), color: const Color(0xFF198754)),
                        _buildQuickBtn('+50k', () => _addAmount(50000), color: const Color(0xFF198754)),
                        _buildQuickBtn('+100k', () => _addAmount(100000), color: const Color(0xFF198754)),
                        _buildQuickBtn('+200k', () => _addAmount(200000), color: const Color(0xFF198754)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // NÚT TRỪ NHANH (-5k, -10k, -20k, -50k)
            Row(
              children: [
                const Text(
                  'Trừ:  ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickBtn('-5k', () => _subtractAmount(5000), color: Colors.red.shade700, isSub: true),
                        _buildQuickBtn('-10k', () => _subtractAmount(10000), color: Colors.red.shade700, isSub: true),
                        _buildQuickBtn('-20k', () => _subtractAmount(20000), color: Colors.red.shade700, isSub: true),
                        _buildQuickBtn('-50k', () => _subtractAmount(50000), color: Colors.red.shade700, isSub: true),
                        _buildQuickBtn('-100k', () => _subtractAmount(100000), color: Colors.red.shade700, isSub: true),
                        // Nút đặt về 0
                        InkWell(
                          onTap: () {
                            if (currentAmount > 0) {
                              if (_isProjectedMode) {
                                widget.onUpdateDay(day.copyWith(projectedAmount: 0));
                              } else {
                                widget.onUpdateDay(day.copyWith(actualAmount: 0));
                              }
                              _showFeedback('Đã đặt về 0₫');
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Về 0',
                              style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dòng nhập số tiền tự do kèm 2 nút [+ Cộng] và [- Trừ]
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền tùy ý (₫)...',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _applyCustom(true),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _applyCustom(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(40, 38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('+ Cộng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () => _applyCustom(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(40, 38),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('- Trừ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBtn(String label, VoidCallback onTap, {required Color color, bool isSub = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
