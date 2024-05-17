import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class ResetDatabaseUseCase {
  OrdersRepository ordersRepository;

  ResetDatabaseUseCase(this.ordersRepository);

  Future<Resource<void>> run() => ordersRepository.resetDatabase();
}
