import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

abstract class AuthRepository {
  Future<AuthResponse?> getUserSession();
  Future<bool> logout();
  Future<void> saveUserSession(AuthResponse authResponse);
  Future<Resource<AuthResponse>> login(String email, String password);
  Future<Resource<AuthResponse>> register(User user);
}
