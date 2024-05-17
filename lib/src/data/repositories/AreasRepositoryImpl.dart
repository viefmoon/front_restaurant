import 'package:restaurante/src/data/dataSource/remote/services/AreasService.dart';
import 'package:restaurante/src/domain/models/Area.dart';
import 'package:restaurante/src/domain/models/Table.dart';
import 'package:restaurante/src/domain/repositories/AreasRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class AreasRepositoryImpl implements AreasRepository {
  AreasService areasService;

  AreasRepositoryImpl(this.areasService);

  @override
  Future<Resource<List<Area>>> getAreas() async {
    return areasService.getAreas();
  }

  @override
  Future<Resource<List<Table>>> getTablesFromArea(int areaId) async {
    return areasService.getTablesFromArea(areaId);
  }
}
