/// Cross-feature data-change events broadcast on the [AppEventBus].
///
/// A cubit that mutates data emits the relevant event after a successful
/// change; screen cubits listen for the events they care about and refresh, so
/// a change on one screen propagates to every affected screen automatically.
/// Add a new subtype here when a future feature introduces a new data domain.
sealed class AppEvent {
  const AppEvent();
}

/// Heal-plan/treatment data changed (task toggled, plan created).
/// Emit this from any future treatment mutation too (e.g. cancel plan).
class TreatmentsChanged extends AppEvent {
  const TreatmentsChanged();
}

/// Scans or rescans changed (new scan/rescan uploaded). Emitted today; a scan
/// history/home widget can subscribe to it for live updates when needed.
class ScansChanged extends AppEvent {
  const ScansChanged();
}

/// The sensor Device ID was set or changed (or cleared). Home unlocks/locks its
/// sensor sections and the notifications center re-pulls sensor alerts.
class SensorDeviceChanged extends AppEvent {
  const SensorDeviceChanged();
}
