import 'dart:convert';
import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/utils/ListToString.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:http/http.dart' as http;
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/models/AuthResponse.dart';

class AuthService {
  Future<Resource<AuthResponse>> login(String username, String password) async {
    try {
      // http://192.168.80.13:3000/auth/login
      Uri url = Uri.http(await ApiConfig.getApiEcommerce(), '/auth/login');
      Map<String, String> headers = {"Content-Type": "application/json"};
      String body = json.encode({'username': username, 'password': password});
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthResponse authResponse = AuthResponse.fromJson(data);
        return Success(authResponse);
      } else {
        // ERROR
        return Error(listToString(data['message']));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<AuthResponse>> register(User user) async {
    try {
      // http://192.168.80.13:3000/auth/register
      Uri url = Uri.http(await ApiConfig.getApiEcommerce(), '/auth/register');
      Map<String, String> headers = {"Content-Type": "application/json"};
      String body = json.encode(user);
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthResponse authResponse = AuthResponse.fromJson(data);
        return Success(authResponse);
      } else {
        return Error(listToString(data['message']));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
