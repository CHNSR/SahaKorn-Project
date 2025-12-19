import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatBaht(double amount, {bool showSign = false}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(amount.abs());
    final suffix = ' ฿';

    if (!showSign) {
      return '$formattedAmount$suffix';
    }

    final sign = amount >= 0 ? '+' : '-';
    // Add space after sign for readability like in the original code '+ 18,000.00' vs '+18,000.00'
    // waiting.. checking original code usage:
    // shop_homepage.dart: '+ 18,000.00 ฿' (with space)
    // shop_transactionpage.dart: '+180.00 ฿' (no space, but some existing have space?)
    // Let's stick to standard no space for now or minimal space.
    // Actually consistent usage is better.

    return '$sign$formattedAmount$suffix';
  }
}
