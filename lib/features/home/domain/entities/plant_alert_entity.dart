enum AlertSeverity { info, warning, critical }

class PlantAlertEntity {
  final String id;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const PlantAlertEntity({
    required this.id,
    required this.message,
    required this.severity,
    required this.timestamp,
  });
}
