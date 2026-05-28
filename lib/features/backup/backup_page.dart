import 'package:flutter/material.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yedekleme')),
      body: const Center(child: Text('Yedekleme araçları Ayarlar ekranından kullanılabilir.')),
    );
  }
}
