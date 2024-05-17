import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';

class GetDeliveryOrdersUseCase {
  OrdersRepository ordersRepository;
  GetDeliveryOrdersUseCase(this.ordersRepository);

  run() => ordersRepository.getDeliveryOrders();
}
