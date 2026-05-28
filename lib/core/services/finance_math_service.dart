class FinanceMathService {
  const FinanceMathService();

  int monthlyBudgetUsagePercent({required int spentMinor, required int budgetMinor}) {
    if (budgetMinor <= 0) return 0;
    return ((spentMinor * 100) / budgetMinor).clamp(0, 999).round();
  }

  int netSavings({required int incomeMinor, required int expenseMinor}) {
    return incomeMinor - expenseMinor;
  }

  int savingsRatePercent({required int incomeMinor, required int expenseMinor}) {
    if (incomeMinor <= 0) return 0;
    final value = ((incomeMinor - expenseMinor) * 100) / incomeMinor;
    return value.round();
  }

  int subscriptionYearlyCost({required int monthlyCostMinor}) {
    return monthlyCostMinor * 12;
  }

  int debtRemaining({required int totalMinor, required int paidMinor}) {
    return totalMinor - paidMinor;
  }

  int financialHealthScore({
    required int incomeMinor,
    required int expenseMinor,
    required int budgetUsagePercent,
    required int subscriptionLoadPercent,
    required int debtLoadPercent,
  }) {
    final ratio = incomeMinor <= 0 ? 0 : ((incomeMinor - expenseMinor) * 100 / incomeMinor).round();
    var score = 50;
    score += ratio.clamp(-20, 30);
    score += (100 - budgetUsagePercent).clamp(-10, 20);
    score += (20 - subscriptionLoadPercent).clamp(-15, 10);
    score += (20 - debtLoadPercent).clamp(-15, 10);
    return score.clamp(0, 100);
  }
}
