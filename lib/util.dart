import 'package:intl/intl.dart';

class Util {
  String formatNumber(num number) {
    final formatter = NumberFormat.compact(locale: 'en');

    if (number < 1000) {
      return number.toString();
    }

    if (number < 1000000) {
      final thousands = (number ~/ 1000).toInt();
      return '${formatter.format(thousands)}K';
    }

    final millions = number / 1000000;
    return '${millions.toStringAsFixed(1)}M';
  }


}
