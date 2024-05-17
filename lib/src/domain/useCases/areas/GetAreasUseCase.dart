import 'package:restaurante/src/domain/repositories/AreasRepository.dart';

class GetAreasUseCase {
  AreasRepository areasRepository;
  GetAreasUseCase(this.areasRepository);

  run() => areasRepository.getAreas();
}
