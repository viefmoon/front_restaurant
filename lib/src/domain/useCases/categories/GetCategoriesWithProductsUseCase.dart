import 'package:restaurante/src/domain/repositories/CategoriesRepository.dart';

class GetCategoriesWithProductsUseCase {
  CategoriesRepository categoriesRepository;
  GetCategoriesWithProductsUseCase(this.categoriesRepository);

  run() => categoriesRepository.getCategoriesWithProducts();
}
