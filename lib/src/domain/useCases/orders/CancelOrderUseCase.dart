import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class CancelOrderUseCase {
  OrdersRepository ordersRepository;

  CancelOrderUseCase(this.ordersRepository);

  Future<Resource<Order>> run(int orderId) =>
      ordersRepository.cancelOrder(orderId);
}
