import 'package:intl/intl.dart';

String formatCurrency(double amount, {String symbol = 'SAR'}) {
  final formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatCTR(double ctr) => '${ctr.toStringAsFixed(2)}%';

String formatCompact(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}K';
  }
  return '$n';
}

String formatDateAbbrev(DateTime date) =>
    DateFormat('MMM d').format(date);

String formatDateFull(DateTime date) =>
    DateFormat('MMM d, yyyy').format(date);

String formatTime(DateTime dt) => DateFormat('HH:mm:ss').format(dt);
