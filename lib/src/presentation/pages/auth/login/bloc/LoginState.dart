import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LoginState extends Equatable {
  final BlocFormItem username;
  final BlocFormItem password;
  final Resource? response;
  final GlobalKey<FormState>? formKey;

  const LoginState(
      {this.username =
          const BlocFormItem(error: 'Ingresa el nombre de usuario'),
      this.password = const BlocFormItem(error: 'Ingresa el passwors'),
      this.formKey,
      this.response});

  LoginState copyWith(
      {BlocFormItem? username,
      BlocFormItem? password,
      Resource? response,
      GlobalKey<FormState>? formKey}) {
    return LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
        formKey: formKey,
        response: response);
  }

  @override
  List<Object?> get props => [username, password, response];
}
