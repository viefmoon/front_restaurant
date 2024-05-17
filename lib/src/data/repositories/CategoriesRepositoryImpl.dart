import 'package:restaurante/src/data/dataSource/remote/services/CategoriesService.dart';
import 'package:restaurante/src/domain/models/Category.dart';
import 'package:restaurante/src/domain/repositories/CategoriesRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesService categoriesService;

  CategoriesRepositoryImpl(this.categoriesService);

  @override
  Future<Resource<List<Category>>> getCategoriesWithProducts() async {
    return categoriesService.getCategoriesWithProducts();
  }
}
