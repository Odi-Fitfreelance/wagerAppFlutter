import '../models/store_item.dart';
import 'api_client.dart';

class StoreService {
  final ApiClient _client;

  StoreService(this._client);

  Future<List<StoreItem>> getItems({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    final response = await _client.get('/store/items', queryParameters: {
      'limit': limit,
      'offset': (page - 1) * limit,
      if (category != null) 'category': category,
    });
    return (response.data['items'] as List)
        .map((json) => StoreItem.fromJson(json))
        .toList();
  }

  Future<Order> purchaseItem({
    required String itemId,
    int quantity = 1,
    Map<String, dynamic>? shippingAddress,
  }) async {
    final response = await _client.post('/store/purchase', data: {
      'itemId': itemId,
      'quantity': quantity,
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
    });
    return Order.fromJson(response.data['order']);
  }

  Future<List<Order>> getOrders() async {
    final response = await _client.get('/store/orders');
    return (response.data['orders'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }
}
