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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F5132), // Dark emerald green
            const Color(0xFF198754), // Forest green
            const Color(0xFF0D6EFD).withValues(alpha: 0.9), // Ocean blue touch
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF198754).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Goal Title and Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(goal.targetAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: onEditGoal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Đổi mục tiêu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2 Summary Cards: TỔNG HIỆN TẠI & TỔNG DỰ KIẾN
            Row(
              children: [
                // Ô 1: Tổng hiện tại (Đã tiết kiệm được)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: Color(0xFF69F0AE)),
                            SizedBox(width: 4),
                            Text(
                              'Tổng Hiện Tại',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.formatCurrency(totalActual),
                            style: const TextStyle(
                              color: Color(0xFFB9F6CA),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đạt $actualPercentText% mục tiêu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ô 2: Tổng dự kiến (Đã có + Dự kiến có thêm)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.trending_up_rounded,
                                size: 14, color: Color(0xFFFFD54F)),
                            SizedBox(width: 4),
                            Text(
                              'Tổng Dự Kiến',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.formatCurrency(totalPotential),
                            style: const TextStyle(
                              color: Color(0xFFFFE082),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khả năng $potentialPercentText% mục tiêu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Progress Bar Visualizer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến trình tiết kiệm',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isTargetReached
                          ? '🎉 Đã hoàn thành mục tiêu!'
                          : 'Còn thiếu ${Formatters.formatCurrency(remainingActual)}',
                      style: TextStyle(
                        color: isTargetReached
                            ? const Color(0xFF69F0AE)
                            : Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Custom layered progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Stack(
                      children: [
                        // Background Projected bar (amber)
                        FractionallySizedBox(
                          widthFactor: potentialPercent,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCA28),
                            ),
                          ),
                        ),
                        // Foreground Actual saved bar (bright green)
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
                const SizedBox(height: 6),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Đã có',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCA28),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Dự kiến thêm',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
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
