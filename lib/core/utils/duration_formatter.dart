/// Utility to format milliseconds into standard speedcubing timer formats.
class DurationFormatter {
  DurationFormatter._();

  /// Formats milliseconds into standard format: "SS.cs" or "M:SS.cs".
  /// Centiseconds (2 decimal digits) is WCA standard, but 3 decimals can be shown.
  static String format(int timeMs, {bool showMilliseconds = true}) {
    if (timeMs < 0) return '0.00';

    final int minutes = timeMs ~/ 60000;
    final int seconds = (timeMs % 60000) ~/ 1000;
    final int millis = timeMs % 1000;

    final String fracPart = showMilliseconds
        ? (millis ~/ 10).toString().padLeft(2, '0') // centiseconds (2 digits)
        : (millis ~/ 100).toString();

    if (minutes > 0) {
      final String secStr = seconds.toString().padLeft(2, '0');
      return '$minutes:$secStr.$fracPart';
    } else {
      return '$seconds.$fracPart';
    }
  }

  /// Formats ISO-8601 string or DateTime into friendly readable relative/absolute date.
  static String formatTimestamp(DateTime dt) {
    final String month = _monthName(dt.month);
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, $hour:$minute';
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
