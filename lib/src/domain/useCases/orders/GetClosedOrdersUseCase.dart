import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';

class GetClosedOrdersUseCase {
  OrdersRepository ordersRepository;
  GetClosedOrdersUseCase(this.ordersRepository);

  run() => ordersRepository.getClosedOrders();
}
