import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginEvent.dart';
import 'LoginState.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> _verifyServerConnection(String serverIp) async {
    try {
      final response = await http.get(Uri.parse('http://$serverIp:3000/ping'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onInitEvent(InitEvent event, Emitter<LoginState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ??
        ''; // Asegúrate de que es seguro guardar la

    emit(state.copyWith(
        username: BlocFormItem(value: username),
        password: BlocFormItem(value: password)));
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    emit(state.copyWith(formKey: formKey));
    if (authResponse != null) {
      // Suponiendo que la IP del servidor se guarda en SharedPreferences y se puede acceder desde aquí
      final prefs = await SharedPreferences.getInstance();
      String serverIp = prefs.getString('serverIP') ?? '';
      bool isConnected = await _verifyServerConnection(serverIp);
      if (isConnected) {
        emit(state.copyWith(
            response: Success(authResponse), // AuthResponse -> user, token
            formKey: formKey));
      } else {
        emit(state.copyWith(
            response: Error(
                'No se pudo conectar con el servidor, verifica la IP del servidor en la configuración, si el problema persiste, verifica que tu conexión wifi sea al servidor o el servidor se encuentre conectado'),
            formKey: formKey));
      }
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
    emit(state.copyWith(response: Loading(), formKey: formKey));
    Resource response = await authUseCases.login
        .run(state.username.value, state.password.value);
    if (response is Success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', state.username.value);
      await prefs.setString(
          'password',
          state.password
              .value); // Asegúrate de que es seguro guardar la contraseña
      emit(state.copyWith(response: response, formKey: formKey));
    } else {
      emit(state.copyWith(response: response, formKey: formKey));
    }
  }
}
