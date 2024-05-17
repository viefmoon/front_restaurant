import 'package:restaurante/src/domain/models/Role.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

abstract class RolesRepository {
  Future<Resource<List<Role>>> getRoles();
}
