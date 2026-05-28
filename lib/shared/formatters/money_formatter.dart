import 'package:intl/intl.dart';

class MoneyFormatter {
  const MoneyFormatter._();

  static String formatMinor({required int minor, required String currency}) {
    final value = minor / 100;
    return NumberFormat.simpleCurrency(name: currency, locale: 'tr_TR').format(value);
  }

  static int? parseTryToMinor(String raw) {
    final cleaned = raw.trim().replaceAll('₺', '').replaceAll('TL', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.contains(',')
        ? cleaned.replaceAll('.', '').replaceAll(',', '.')
        : cleaned;
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return (value * 100).round();
  }

  static String formatMinorForInput(int minor) {
    final value = minor / 100;
    return NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(value).trim();
  }
}
