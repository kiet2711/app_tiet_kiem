import 'package:flutter/material.dart';
import '../models/saving_day.dart';
import '../utils/formatters.dart';

class DailyCardListView extends StatelessWidget {
  final List<SavingDay> days;
  final Function(SavingDay) onEdit;
  final Function(String id) onDelete;
  final Function(SavingDay) onTransferProjected;

  const DailyCardListView({
    super.key,
    required this.days,
    required this.onEdit,
    required this.onDelete,
    required this.onTransferProjected,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onEdit(day),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Date & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF198754).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Color(0xFF198754),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.formatDateWithWeekday(day.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onEdit(day),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onDelete(day.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: 2 Boxes (Đã tiết kiệm & Có thể tiết kiệm)
                  Row(
                    children: [
                      // Ô 1: Đã tiết kiệm
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 12, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đã tiết kiệm',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  Formatters.formatCurrency(day.actualAmount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Ô 2: Có thể tiết kiệm
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb, size: 12, color: Color(0xFFE65100)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Có thể tiết kiệm',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  Formatters.formatCurrency(day.projectedAmount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Nút chuyển nhanh dự kiến sang đã tiết kiệm
                  if (day.projectedAmount > 0) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => onTransferProjected(day),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF198754).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF198754).withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.published_with_changes_rounded, size: 16, color: Color(0xFF198754)),
                            const SizedBox(width: 6),
                            Text(
                              'Chuyển ${Formatters.formatCurrency(day.projectedAmount)} sang ĐÃ TIẾT KIỆM',
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

                  // Note if present
                  if (day.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.comment_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            day.note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
