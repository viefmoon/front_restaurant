import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';

class GetOpenOrdersUseCase {
  OrdersRepository ordersRepository;
  GetOpenOrdersUseCase(this.ordersRepository);

  run() => ordersRepository.getOpenOrders();
}
