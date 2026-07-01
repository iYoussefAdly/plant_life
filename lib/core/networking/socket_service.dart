import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Thin wrapper over the Socket.IO client for live server events. Stays in
/// `core/` with no dependency on feature code — features consume [onNotificationNew]
/// via the data layer.
class SocketService {
  final TokenStorage _tokenStorage;
  io.Socket? _socket;
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  SocketService(this._tokenStorage);

  /// Payload of each server `notification:new` event.
  Stream<Map<String, dynamic>> get onNotificationNew =>
      _notificationController.stream;

  /// Connects using the stored access token in the handshake auth. Safe to call
  /// repeatedly — a no-op if already connected. Connection failures are
  /// non-fatal (the REST flow still works).
  Future<void> connect() async {
    if (_socket != null) return;
    try {
      final token = await _tokenStorage.getAccessToken();
      // The socket connects to the API host (base URL minus the `/api` suffix).
      final host = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

      final socket = io.io(
        host,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setAuth({'token': token})
            .build(),
      );
      socket.on('notification:new', (data) {
        if (data is Map) {
          _notificationController.add(Map<String, dynamic>.from(data));
        }
      });
      // The access token may have been refreshed by the HTTP layer while the
      // socket was down — refresh the handshake auth before each reconnect so
      // we never retry with a stale/expired token.
      socket.onConnectError((_) => _refreshAuth(socket));
      socket.connect();
      _socket = socket;
    } catch (_) {
      _socket = null;
    }
  }

  Future<void> _refreshAuth(io.Socket socket) async {
    try {
      socket.auth = {'token': await _tokenStorage.getAccessToken()};
    } catch (_) {
      // Keep the existing auth if storage read fails.
    }
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  /// Closes the socket and the event stream — for teardown/tests.
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
