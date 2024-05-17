import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/models/Role.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class RolesService {
  Future<Resource<List<Role>>> getRoles() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/roles');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Role> roles =
            data.map((dynamic item) => Role.fromJson(item)).toList();
        return Success(roles);
      } else {
        return Error("Error al recuperar los roles: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
