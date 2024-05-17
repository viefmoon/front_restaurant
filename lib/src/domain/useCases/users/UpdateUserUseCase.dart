import 'dart:io';

import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/repositories/UsersRepository.dart';

class UpdateUserUseCase {
  UsersRepository usersRepository;

  UpdateUserUseCase(this.usersRepository);

  run(int id, User user, File? file) => usersRepository.update(id, user);
}
