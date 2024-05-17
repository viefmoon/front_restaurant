import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'LoginEvent.dart';
import 'LoginState.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthUseCases authUseCases;

  LoginBloc(this.authUseCases) : super(LoginState()) {
    on<InitEvent>(_onInitEvent);
    on<UsernameChanged>(_onUsernameChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmit>(_onLoginSubmit);
    on<LoginFormReset>(_onLoginFormReset);
    on<LoginSaveUserSession>(_onLoginSaveUserSession);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _onInitEvent(InitEvent event, Emitter<LoginState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    emit(state.copyWith(formKey: formKey));
    if (authResponse != null) {
      emit(state.copyWith(
          response: Success(authResponse), // AuthResponse -> user, token
          formKey: formKey));
    }
  }

  Future<void> _onLoginSaveUserSession(
      LoginSaveUserSession event, Emitter<LoginState> emit) async {
    await authUseCases.saveUserSession.run(event.authResponse);
  }

  Future<void> _onLoginFormReset(
      LoginFormReset event, Emitter<LoginState> emit) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onUsernameChanged(
      UsernameChanged event, Emitter<LoginState> emit) async {
    emit(state.copyWith(
        username: BlocFormItem(
            value: event.username.value,
            error: event.username.value.isNotEmpty
                ? null
                : 'Ingresa el nombre de usuario'),
        formKey: formKey));
  }

  Future<void> _onPasswordChanged(
      PasswordChanged event, Emitter<LoginState> emit) async {
    emit(state.copyWith(
        password: BlocFormItem(
            value: event.password.value,
            error: event.password.value.isNotEmpty &&
                    event.password.value.length >= 6
                ? null
                : 'Ingresa el password'),
        formKey: formKey));
  }

  Future<void> _onLoginSubmit(
      LoginSubmit event, Emitter<LoginState> emit) async {
    emit(
      state.copyWith(response: Loading(), formKey: formKey),
    );
    Resource response = await authUseCases.login
        .run(state.username.value, state.password.value);
    emit(state.copyWith(response: response, formKey: formKey));
  }
}
