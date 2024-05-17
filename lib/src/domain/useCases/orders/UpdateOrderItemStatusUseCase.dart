import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class UpdateOrderItemStatusUseCase {
  OrdersRepository ordersRepository;

  UpdateOrderItemStatusUseCase(this.ordersRepository);

  Future<Resource<OrderItem>> run(OrderItem orderItem) =>
      ordersRepository.updateOrderItemStatus(orderItem);
}
