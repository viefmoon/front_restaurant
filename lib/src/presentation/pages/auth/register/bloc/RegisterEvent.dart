import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterInitEvent extends RegisterEvent {
  const RegisterInitEvent();
}

class RegisterNameChanged extends RegisterEvent {
  final BlocFormItem name;
  const RegisterNameChanged({required this.name});
  @override
  List<Object?> get props => [name];
}

class RegisterUsernameChanged extends RegisterEvent {
  final BlocFormItem username;
  const RegisterUsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}

class RegisterPasswordChanged extends RegisterEvent {
  final BlocFormItem password;
  const RegisterPasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}

class RegisterFormSubmit extends RegisterEvent {
  const RegisterFormSubmit();
}

class RegisterFormReset extends RegisterEvent {
  const RegisterFormReset();
}

class LoadRoles extends RegisterEvent {
  const LoadRoles();
}

class RoleSelected extends RegisterEvent {
  final BlocFormItem roleId;
  const RoleSelected({required this.roleId});
  @override
  List<Object?> get props => [roleId];
}
