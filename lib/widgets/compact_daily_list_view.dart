import 'package:flutter/material.dart';
import '../models/saving_day.dart';
import '../utils/formatters.dart';

class CompactDailyListView extends StatelessWidget {
  final List<SavingDay> days;
  final String activeDayId;
  final Function(SavingDay) onSelectActiveDay;
  final Function(SavingDay) onTransferProjected;
  final Function(SavingDay) onEdit;
  final Function(String id) onDelete;

  const CompactDailyListView({
    super.key,
    required this.days,
    required this.activeDayId,
    required this.onSelectActiveDay,
    required this.onTransferProjected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.savings_outlined, size: 40, color: Colors.green.shade300),
              const SizedBox(height: 8),
              const Text(
                'Chưa có ngày ghi chép nào',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bấm vào các nút +5k, +10k ở trên để tự động ghi nhận nhé!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isActive = day.id == activeDayId;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? const Color(0xFF198754) : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelectActiveDay(day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dòng 1: Tên ngày + Đang chọn badge + Tổng ngày
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isActive ? const Color(0xFF198754) : Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.formatDateWithWeekday(day.date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isActive ? const Color(0xFF0F5132) : Colors.black87,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF198754).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Đang nhập',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF198754),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        Formatters.formatCurrency(day.totalDayPotential),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dòng 2: 2 Ô ĐÃ CÓ & DỰ KIẾN (Vừa vặn 100% màn hình, không tràn ngang)
                  Row(
                    children: [
                      // Đã tiết kiệm
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 12, color: Color(0xFF2E7D32)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Đã có: ${Formatters.formatNumber(day.actualAmount)}₫',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Có thể tiết kiệm
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb, size: 12, color: Color(0xFFF57F17)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Dự kiến: ${Formatters.formatNumber(day.projectedAmount)}₫',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Dòng 3: Ghi chú hoặc Nút chuyển nhanh nếu có dự kiến
                  if (day.projectedAmount > 0 || day.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (day.note.isNotEmpty)
                          Expanded(
                            child: Text(
                              day.note,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),

                        if (day.projectedAmount > 0)
                          InkWell(
                            onTap: () => onTransferProjected(day),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF198754).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.published_with_changes, size: 12, color: Color(0xFF198754)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Chuyển sang Đã có',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF198754),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Menu sửa / xóa nhỏ gọn
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (val) {
                            if (val == 'edit') onEdit(day);
                            if (val == 'delete') onDelete(day.id);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16, color: Colors.blue),
                                  SizedBox(width: 6),
                                  Text('Sửa chi tiết & ghi chú'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text('Xóa ngày này'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
