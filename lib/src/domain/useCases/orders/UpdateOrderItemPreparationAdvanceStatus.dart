import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class UpdateOrderItemPreparationAdvanceStatusUseCase {
  OrdersRepository ordersRepository;

  UpdateOrderItemPreparationAdvanceStatusUseCase(this.ordersRepository);

  Future<Resource<OrderItem>> run(
          int orderId, int orderItemId, bool isBeingPreparedInAdvance) =>
      ordersRepository.updateOrderItemPreparationAdvanceStatus(
          orderId, orderItemId, isBeingPreparedInAdvance);
}
