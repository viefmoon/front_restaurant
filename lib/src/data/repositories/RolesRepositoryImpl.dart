import 'package:restaurante/src/data/dataSource/remote/services/RolesService.dart';
import 'package:restaurante/src/domain/models/Role.dart';
import 'package:restaurante/src/domain/repositories/RolesRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class RolesRepositoryImpl implements RolesRepository {
  RolesService rolesService;

  RolesRepositoryImpl(this.rolesService);

  @override
  Future<Resource<List<Role>>> getRoles() async {
    return rolesService.getRoles();
  }
}
