import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';

class GetSalesReportUseCase {
  OrdersRepository ordersRepository;
  GetSalesReportUseCase(this.ordersRepository);

  run() => ordersRepository.getSalesReport();
}
