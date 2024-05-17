import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';

class FindOrderItemsWithCountsUseCase {
  OrdersRepository ordersRepository;
  FindOrderItemsWithCountsUseCase(this.ordersRepository);

  run({required List<String> subcategories, required int ordersLimit}) =>
      ordersRepository.findOrderItemsWithCounts(
          subcategories: subcategories, ordersLimit: ordersLimit);
}
