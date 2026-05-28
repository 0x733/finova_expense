import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class ExportImportService {
  const ExportImportService(this._db);

  final AppDatabase _db;

  Future<String> exportJson() async {
    final txs = await _db.select(_db.transactions).get();
    final data = txs.map((e) => e.toJson()).toList(growable: false);
    return jsonEncode({'transactions': data});
  }

  Future<String> exportCsv() async {
    final txs = await _db.select(_db.transactions).get();
    final rows = <String>['id,type,amountMinor,dateEpochSeconds,walletId,categoryId,note'];
    for (final tx in txs) {
      rows.add('${tx.id},${tx.type},${tx.amountMinor},${tx.dateEpochSeconds},${tx.walletId},${tx.categoryId},${tx.note ?? ''}');
    }
    return rows.join('\n');
  }

  Future<void> shareExport(String content, String extension) async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = XFile.fromData(
      utf8.encode(content),
      mimeType: extension == 'json' ? 'application/json' : 'text/csv',
      name: 'finova_export_$timestamp.$extension',
    );
    await SharePlus.instance.share(ShareParams(files: [file]));
  }

  Future<String> importJsonFromPicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.bytes == null) {
      return 'Dosya seçilmedi';
    }
    final raw = utf8.decode(result.files.single.bytes!);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['transactions'] is! List) {
      return 'Geçersiz JSON formatı';
    }
    return 'İçe aktarma doğrulaması başarılı';
  }
}
