import 'package:restaurante/src/domain/models/User.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:restaurante/src/domain/models/Role.dart';

class RegisterState extends Equatable {
  final BlocFormItem name;
  final BlocFormItem username;
  final BlocFormItem password;
  final GlobalKey<FormState>? formKey;
  final Resource? response;
  final List<Role>? roles;
  final BlocFormItem roleId;

  const RegisterState({
    this.name = const BlocFormItem(error: 'Ingresa el nombre'),
    this.username = const BlocFormItem(error: 'Ingresa el nombre de usuario'),
    this.password = const BlocFormItem(error: 'Ingresa el password'),
    this.formKey,
    this.response,
    this.roles,
    this.roleId = const BlocFormItem(error: 'Selecciona un rol'),
  });

  toUser() => User(
      name: name.value,
      username: username.value,
      password: password.value,
      roleId: roleId.value);

  RegisterState copyWith({
    BlocFormItem? name,
    BlocFormItem? username,
    BlocFormItem? password,
    GlobalKey<FormState>? formKey,
    Resource? response,
    List<Role>? roles,
    BlocFormItem? roleId,
  }) {
    return RegisterState(
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      formKey: formKey,
      response: response,
      roles: roles ?? this.roles,
      roleId: roleId ?? this.roleId,
    );
  }

  @override
  List<Object?> get props =>
      [name, username, password, formKey, response, roles, roleId];
}
