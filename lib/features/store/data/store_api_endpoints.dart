/// Endpoints for the (separate) Plant Store backend.
///
/// The store is a different service from the plant-life API — its own host,
/// own auth token, and a `{ status, data }` envelope. The `http://` host
/// 301-redirects to `https://`, so we use HTTPS directly (no cleartext).
abstract final class StoreApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'STORE_API_BASE_URL',
    defaultValue: 'https://plantstore-production-6cbf.up.railway.app/api/v1',
  );

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const me = '/auth/me';

  // Products
  static const products = '/products';
  static String product(String id) => '/products/$id';

  // Cart
  static const cart = '/cart';
  static String cartItem(String productId) => '/cart/$productId';

  // Orders
  static const orders = '/orders';
  static const myOrders = '/orders/my-orders';
  static String order(String id) => '/orders/$id';

  // Payment
  static const checkoutSession = '/payment/checkout-session';
}
