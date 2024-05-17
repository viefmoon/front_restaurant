import 'package:restaurante/src/domain/repositories/AuthRepository.dart';

class LoginUseCase {
  AuthRepository repository;

  LoginUseCase(this.repository);

  run(String email, String password) => repository.login(email, password);
}
