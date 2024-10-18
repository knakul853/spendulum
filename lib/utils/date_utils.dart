import 'package:intl/intl.dart';

class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
}
