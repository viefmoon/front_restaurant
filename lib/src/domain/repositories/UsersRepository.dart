import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

abstract class UsersRepository {
  Future<Resource<User>> update(int id, User user);
}
