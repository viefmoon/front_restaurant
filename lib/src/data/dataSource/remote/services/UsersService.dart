import 'dart:convert';
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/utils/ListToString.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:http/http.dart' as http;

class UsersService {
  Future<String> token;

  UsersService(this.token);

  Future<Resource<User>> update(int id, User user) async {
    try {
      // http://192.168.80.13:3000/users/5
      Uri url = Uri.http(await ApiConfig.getApiEcommerce(), '/users/$id');
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": await token
      };
      String body = json.encode({
        'name': user.name,
        'username': user.username,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      } else {
        // ERROR
        return Error(listToString(data['message']));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
