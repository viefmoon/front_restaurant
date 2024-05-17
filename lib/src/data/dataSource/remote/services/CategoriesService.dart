import 'dart:convert';
import 'package:restaurante/src/domain/models/Category.dart';
import 'package:http/http.dart' as http;
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class CategoriesService {
  Future<Resource<List<Category>>> getCategoriesWithProducts() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/categories');
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = json.decode(response.body);
        List<Category> categories =
            data.map((dynamic item) => Category.fromJson(item)).toList();
        return Success(categories);
      } else {
        return Error("Error al recuperar las áreas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
