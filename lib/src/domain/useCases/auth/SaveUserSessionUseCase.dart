import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/repositories/AuthRepository.dart';

class SaveUserSessionUseCase {
  AuthRepository authRepository;
  SaveUserSessionUseCase(this.authRepository);

  run(AuthResponse authResponse) =>
      authRepository.saveUserSession(authResponse);
}
