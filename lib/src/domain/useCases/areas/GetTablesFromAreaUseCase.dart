import 'package:restaurante/src/domain/repositories/AreasRepository.dart';

class GetTablesFromAreaUseCase {
  AreasRepository areasRepository;
  GetTablesFromAreaUseCase(this.areasRepository);

  run(int areaId) => areasRepository.getTablesFromArea(areaId);
}
