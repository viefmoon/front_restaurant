import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class RevertMultipleOrdersUseCase {
  OrdersRepository ordersRepository;

  RevertMultipleOrdersUseCase(this.ordersRepository);

  Future<Resource<List<Order>>> run(List<int> orderIds) =>
      ordersRepository.revertMultipleOrdersToPrepared(orderIds);
}
