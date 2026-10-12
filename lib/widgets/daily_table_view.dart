import 'package:flutter/material.dart';
import '../models/saving_day.dart';
import '../utils/formatters.dart';

class DailyTableView extends StatelessWidget {
  final List<SavingDay> days;
  final Function(SavingDay) onEdit;
  final Function(String id) onDelete;
  final Function(SavingDay updatedDay) onUpdateQuick;
  final Function(SavingDay) onTransferProjected;

  const DailyTableView({
    super.key,
    required this.days,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateQuick,
    required this.onTransferProjected,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.table_chart_outlined,
                  size: 48,
                  color: Color(0xFF198754),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bảng tính chưa có ngày nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy bấm nút "Nhập ngày mới" để bắt đầu ghi chép ngày tiết kiệm đầu tiên của bạn!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF1F8F5),
              ),
              horizontalMargin: 16,
              columnSpacing: 20,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              columns: const [
                DataColumn(
                  label: Text(
                    'Ngày',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5132),
                    ),
                  ),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Color(0xFF198754)),
                      SizedBox(width: 4),
                      Text(
                        'Đã tiết kiệm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF198754),
                        ),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      Icon(Icons.lightbulb, size: 14, color: Color(0xFFE65100)),
                      SizedBox(width: 4),
                      Text(
                        'Có thể tiết kiệm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tổng ngày',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Thao tác',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
              rows: days.map((day) {
                return DataRow(
                  cells: [
                    // Cột 1: Ngày
                    DataCell(
                      InkWell(
                        onTap: () => onEdit(day),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.formatDate(day.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (day.note.isNotEmpty)
                              Text(
                                day.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Cột 2: Đã tiết kiệm được (Ô 1)
                    DataCell(
                      InkWell(
                        onTap: () => onEdit(day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Text(
                            '${Formatters.formatNumber(day.actualAmount)} ₫',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cột 3: Có thể sẽ tiết kiệm được (Ô 2)
                    DataCell(
                      InkWell(
                        onTap: () => onEdit(day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Text(
                            '${Formatters.formatNumber(day.projectedAmount)} ₫',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cột 4: Tổng ngày (Đã có + Dự kiến)
                    DataCell(
                      Text(
                        Formatters.formatCurrency(day.totalDayPotential),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    // Cột 5: Thao tác (Sửa / Xóa)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (day.projectedAmount > 0)
                            IconButton(
                              icon: const Icon(Icons.published_with_changes_rounded, size: 18, color: Color(0xFF198754)),
                              tooltip: 'Chuyển ${Formatters.formatCurrency(day.projectedAmount)} sang đã tiết kiệm',
                              onPressed: () => onTransferProjected(day),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            tooltip: 'Chỉnh sửa',
                            onPressed: () => onEdit(day),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            tooltip: 'Xóa ngày này',
                            onPressed: () => onDelete(day.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
