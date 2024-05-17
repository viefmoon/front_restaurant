import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class MarkOrdersAsInDeliveryUseCase {
  final OrdersRepository ordersRepository;

  MarkOrdersAsInDeliveryUseCase(this.ordersRepository);

  Future<Resource<void>> run(List<Order> orders) {
    return ordersRepository.markOrdersAsInDelivery(orders);
  }
}
