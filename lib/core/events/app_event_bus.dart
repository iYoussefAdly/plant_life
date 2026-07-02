import 'dart:async';

import 'app_event.dart';

/// App-wide event bus for automatic cross-feature synchronization.
///
/// Usage:
/// - A cubit that changes data calls [emit] after the change succeeds, e.g.
///   `_eventBus.emit(const TreatmentsChanged())`.
/// - A screen cubit subscribes to the events it cares about in its constructor
///   and refreshes, e.g. `_eventBus.on<TreatmentsChanged>().listen((_) => load())`,
///   cancelling the subscription in `close()`.
///
/// This keeps every affected screen up to date without manual pull-to-refresh,
/// and future features participate simply by emitting/listening — no bespoke
/// refresh wiring per screen.
class AppEventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  /// Stream of events of type [T] only.
  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  void emit(AppEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void dispose() => _controller.close();
}
