import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'vi_VN');

  /// Định dạng tiền tệ: 1.000.000 ₫
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Định dạng số nguyên có dấu chấm ngăn cách: 1.000.000
  static String formatNumber(double amount) {
    return _numberFormat.format(amount.round());
  }

  /// Định dạng ngày: dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Định dạng ngày kèm thứ: Thứ 2, 12/10/2026
  static String formatDateWithWeekday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hôm nay (${DateFormat('dd/MM').format(date)})';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua (${DateFormat('dd/MM').format(date)})';
    }

    const weekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    final weekdayName = weekdays[date.weekday - 1];
    return '$weekdayName, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  /// Chuyển đổi text sang double an toàn, loại bỏ dấu chấm/phẩy/ký hiệu tiền
  static double parseDouble(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0.0;
    return double.tryParse(cleaned) ?? 0.0;
  }
}
