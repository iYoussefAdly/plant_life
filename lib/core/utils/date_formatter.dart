const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a date as a short month + day, e.g. `Jul 1`.
String formatShortDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';
