import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class CompleteMultipleOrdersUseCase {
  OrdersRepository ordersRepository;

  CompleteMultipleOrdersUseCase(this.ordersRepository);

  Future<Resource<List<Order>>> run(List<int> orderIds) =>
      ordersRepository.completeMultipleOrders(orderIds);
}
