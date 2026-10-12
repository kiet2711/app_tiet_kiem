import 'package:flutter/material.dart';
import '../models/saving_goal.dart';
import '../utils/formatters.dart';

class GoalSummaryCard extends StatelessWidget {
  final SavingGoal goal;
  final double totalActual;
  final double totalProjectedAdditional;
  final VoidCallback onEditGoal;

  const GoalSummaryCard({
    super.key,
    required this.goal,
    required this.totalActual,
    required this.totalProjectedAdditional,
    required this.onEditGoal,
  });

  // Tổng dự kiến toàn bộ = Đã tiết kiệm + Có thể tiết kiệm thêm
  double get totalPotential => totalActual + totalProjectedAdditional;

  @override
  Widget build(BuildContext context) {
    final target = goal.targetAmount > 0 ? goal.targetAmount : 1.0;

    final actualPercent = (totalActual / target).clamp(0.0, 1.0);
    final potentialPercent = (totalPotential / target).clamp(0.0, 1.0);

    final actualPercentText = (actualPercent * 100).toStringAsFixed(1);
    final potentialPercentText = (potentialPercent * 100).toStringAsFixed(1);

    final remainingActual = (target - totalActual).clamp(0.0, double.infinity);
    final isTargetReached = totalActual >= target;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F5132), // Dark emerald
            const Color(0xFF198754), // Forest green
            const Color(0xFF0D6EFD).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF198754).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dòng 1: Mục tiêu & Nút sửa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Mục tiêu: ${Formatters.formatCurrency(goal.targetAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onEditGoal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Đổi',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dòng 2: 2 Ô TỔNG HIỆN TẠI & TỔNG DỰ KIẾN
            Row(
              children: [
                // Ô 1: Tổng hiện tại (Đã có)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ĐÃ TIẾT KIỆM',
                          style: TextStyle(
                            color: Color(0xFFB9F6CA),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.formatCurrency(totalActual),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Đạt $actualPercentText%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Ô 2: Tổng dự kiến (Tiềm năng)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TỔNG DỰ KIẾN',
                          style: TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.formatCurrency(totalPotential),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'Khả năng $potentialPercentText%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dòng 3: Thanh tiến trình gọn gàng
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 7,
                color: Colors.black.withValues(alpha: 0.25),
                child: Stack(
                  children: [
                    // Dự kiến (Amber)
                    FractionallySizedBox(
                      widthFactor: potentialPercent,
                      child: Container(
                        decoration: const BoxDecoration(color: Color(0xFFFFCA28)),
                      ),
                    ),
                    // Thực tế (Bright Green)
                    FractionallySizedBox(
                      widthFactor: actualPercent,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Dòng 4: Còn thiếu bao nhiêu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTargetReached
                      ? '🎉 Đã đạt mục tiêu!'
                      : 'Còn thiếu: ${Formatters.formatCurrency(remainingActual)}',
                  style: TextStyle(
                    color: isTargetReached ? const Color(0xFF69F0AE) : Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                    const SizedBox(width: 3),
                    const Text('Đã có', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    const SizedBox(width: 8),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFFCA28), shape: BoxShape.circle)),
                    const SizedBox(width: 3),
                    const Text('Dự kiến', style: TextStyle(color: Colors.white70, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
