import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardNavBar extends StatelessWidget {
  const DashboardNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'İşlemler'),
        NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label: 'Analitik'),
        NavigationDestination(icon: Icon(Icons.savings_rounded), label: 'Bütçe'),
        NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Ayarlar'),
      ],
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/transactions');
            break;
          case 2:
            context.go('/analytics');
            break;
          case 3:
            context.go('/budgets');
            break;
          case 4:
            context.go('/settings');
            break;
        }
      },
    );
  }
}
