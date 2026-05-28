import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

enum WalletType { cash, bank, creditCard, savings, crypto, other }

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    this.monthlyLimitMinor,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final TransactionType type;
  final Color color;
  final IconData icon;
  final int? monthlyLimitMinor;
  final bool isActive;
  final int sortOrder;
}

class WalletModel {
  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.color,
    required this.icon,
    this.initialBalanceMinor = 0,
    this.currentBalanceMinor = 0,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final WalletType type;
  final String currency;
  final Color color;
  final IconData icon;
  final int initialBalanceMinor;
  final int currentBalanceMinor;
  final bool isArchived;
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.date,
    required this.walletId,
    required this.categoryId,
    this.note,
    this.tags = const [],
    this.isRecurring = false,
    this.isFavorite = false,
  });

  final String id;
  final TransactionType type;
  final int amountMinor;
  final DateTime date;
  final String walletId;
  final String categoryId;
  final String? note;
  final List<String> tags;
  final bool isRecurring;
  final bool isFavorite;
}

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.period,
    this.categoryId,
  });

  final String id;
  final String name;
  final int amountMinor;
  final String period;
  final String? categoryId;
}

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.renewalDate,
    required this.period,
    required this.categoryId,
    this.reminder = true,
  });

  final String id;
  final String name;
  final int amountMinor;
  final DateTime renewalDate;
  final String period;
  final String categoryId;
  final bool reminder;
}

class DebtModel {
  const DebtModel({
    required this.id,
    required this.personName,
    required this.amountMinor,
    required this.paidMinor,
    required this.dueDate,
    required this.isReceivable,
  });

  final String id;
  final String personName;
  final int amountMinor;
  final int paidMinor;
  final DateTime dueDate;
  final bool isReceivable;

  int get remainingMinor => amountMinor - paidMinor;
}

class SavingsGoalModel {
  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetMinor,
    required this.currentMinor,
    required this.targetDate,
  });

  final String id;
  final String name;
  final int targetMinor;
  final int currentMinor;
  final DateTime targetDate;
}
