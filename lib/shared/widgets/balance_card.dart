import 'package:flutter/material.dart';

import '../../shared/formatters/money_formatter.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.totalBalanceMinor,
    required this.currency,
    required this.monthlyIncomeMinor,
    required this.monthlyExpenseMinor,
    required this.netSavingsMinor,
  });

  final int totalBalanceMinor;
  final String currency;
  final int monthlyIncomeMinor;
  final int monthlyExpenseMinor;
  final int netSavingsMinor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Toplam Bakiye', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            MoneyFormatter.formatMinor(minor: totalBalanceMinor, currency: currency),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricTile(label: 'Bu ay gelir', value: MoneyFormatter.formatMinor(minor: monthlyIncomeMinor, currency: currency)),
              const SizedBox(width: 12),
              _MetricTile(label: 'Bu ay gider', value: MoneyFormatter.formatMinor(minor: monthlyExpenseMinor, currency: currency)),
              const SizedBox(width: 12),
              _MetricTile(label: 'Net', value: MoneyFormatter.formatMinor(minor: netSavingsMinor, currency: currency)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
