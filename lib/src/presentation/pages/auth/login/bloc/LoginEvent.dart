import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends LoginEvent {
  const InitEvent();
}

class LoginFormReset extends LoginEvent {
  const LoginFormReset();
}

class LoginSaveUserSession extends LoginEvent {
  final AuthResponse authResponse;
  const LoginSaveUserSession({required this.authResponse});

  @override
  List<Object?> get props => [authResponse];
}

class UsernameChanged extends LoginEvent {
  final BlocFormItem username;
  const UsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}

class PasswordChanged extends LoginEvent {
  final BlocFormItem password;
  const PasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}

class LoginSubmit extends LoginEvent {
  const LoginSubmit();
}
