const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a date as a short month + day, e.g. `Jul 1`.
String formatShortDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';

/// Formats a price in EGP, e.g. `125 EGP` (whole) or `99.50 EGP`.
String formatPrice(num value) {
  final str = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return '$str EGP';
}

/// Relative "time ago" label, e.g. `just now`, `5m ago`, `3h ago`, `2d ago`.
String formatTimeAgo(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
