/// Formatting utility functions for currency, numbers, dates, and percentages.
///
/// This library provides consistent formatting across the app for:
/// - Currency values with locale-aware formatting
/// - CTR (Click-Through Rate) percentages
/// - Large numbers with K/M suffixes
/// - Dates in various formats
///
/// All formatters use the `intl` package for internationalization support.
library;

import 'package:intl/intl.dart';

/// Formats a currency amount with thousand separators and a currency symbol.
///
/// The default currency is SAR (Saudi Riyal). No decimal places are shown.
///
/// **Examples:**
/// ```dart
/// formatCurrency(1234.56)           // "SAR 1,235"
/// formatCurrency(50000)             // "SAR 50,000"
/// formatCurrency(1000, symbol: '$') // "$1,000"
/// ```
///
/// **Parameters:**
/// - [amount]: The numeric amount to format
/// - [symbol]: The currency symbol to display (defaults to 'SAR')
///
/// **Returns:** A formatted currency string with thousand separators
String formatCurrency(double amount, {String symbol = 'SAR'}) {
  final formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Formats a CTR (Click-Through Rate) value as a percentage with 2 decimal places.
///
/// **Examples:**
/// ```dart
/// formatCTR(4.567)  // "4.57%"
/// formatCTR(0.123)  // "0.12%"
/// formatCTR(10.0)   // "10.00%"
/// ```
///
/// **Parameters:**
/// - [ctr]: The CTR value to format (as a decimal, e.g., 4.5 for 4.5%)
///
/// **Returns:** A formatted percentage string with 2 decimal places
String formatCTR(double ctr) => '${ctr.toStringAsFixed(2)}%';

/// Formats large integers with K (thousands) or M (millions) suffixes for compact display.
///
/// Numbers below 1,000 are displayed as-is. Larger numbers are shortened with
/// appropriate suffixes and 1 decimal place if needed.
///
/// **Examples:**
/// ```dart
/// formatCompact(500)       // "500"
/// formatCompact(1200)      // "1.2K"
/// formatCompact(5000)      // "5K"
/// formatCompact(1500000)   // "1.5M"
/// formatCompact(10000000)  // "10M"
/// ```
///
/// **Parameters:**
/// - [n]: The integer to format
///
/// **Returns:** A compact string representation with K/M suffix if applicable
///
/// **Use cases:**
/// - Displaying impression counts
/// - Showing click numbers
/// - Compact stat displays in cards
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

/// Formats a date in abbreviated month and day format (e.g., "Jan 5").
///
/// Used for compact date displays in charts and lists.
///
/// **Examples:**
/// ```dart
/// formatDateAbbrev(DateTime(2024, 1, 5))   // "Jan 5"
/// formatDateAbbrev(DateTime(2024, 12, 25)) // "Dec 25"
/// ```
///
/// **Parameters:**
/// - [date]: The DateTime to format
///
/// **Returns:** Abbreviated date string in "MMM d" format
String formatDateAbbrev(DateTime date) =>
    DateFormat('MMM d').format(date);

/// Formats a date in full month, day, and year format (e.g., "Jan 5, 2024").
///
/// Used for detailed date displays in headers and detailed views.
///
/// **Examples:**
/// ```dart
/// formatDateFull(DateTime(2024, 1, 5))   // "Jan 5, 2024"
/// formatDateFull(DateTime(2024, 12, 25)) // "Dec 25, 2024"
/// ```
///
/// **Parameters:**
/// - [date]: The DateTime to format
///
/// **Returns:** Full date string in "MMM d, yyyy" format
String formatDateFull(DateTime date) =>
    DateFormat('MMM d, yyyy').format(date);

/// Formats a DateTime as a time string in 24-hour format (e.g., "14:30:25").
///
/// Used for displaying timestamps, polling status, and anomaly detection times.
///
/// **Examples:**
/// ```dart
/// formatTime(DateTime(2024, 1, 5, 14, 30, 25)) // "14:30:25"
/// formatTime(DateTime(2024, 1, 5, 9, 5, 3))    // "09:05:03"
/// ```
///
/// **Parameters:**
/// - [dt]: The DateTime to format
///
/// **Returns:** Time string in "HH:mm:ss" format (24-hour)
String formatTime(DateTime dt) => DateFormat('HH:mm:ss').format(dt);
