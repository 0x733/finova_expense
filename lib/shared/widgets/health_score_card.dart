import 'package:flutter/material.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? const Color(0xFF10B981)
        : score >= 40
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final label = score >= 70 ? 'İyi' : score >= 40 ? 'Orta' : 'Dikkat';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 5,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finansal Sağlık Skoru',
                    style: Theme.of(context).textTheme.labelMedium),
                Text(
                  '$score / 100 – $label',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
