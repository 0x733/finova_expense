import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String short(DateTime value) => DateFormat('dd MMM yyyy', 'tr_TR').format(value);
}
