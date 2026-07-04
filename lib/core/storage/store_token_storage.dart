import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the (separate) store-backend auth token. Kept apart from the
/// plant-life [TokenStorage] because the two backends have independent auth.
class StoreTokenStorage {
  final FlutterSecureStorage _storage;
  const StoreTokenStorage(this._storage);

  static const _tokenKey = 'store_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }
}
