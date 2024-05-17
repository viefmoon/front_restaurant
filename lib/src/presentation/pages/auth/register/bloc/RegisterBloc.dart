import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/useCases/roles/RolesUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/models/Role.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  AuthUseCases authUseCases;
  RolesUseCases rolesUseCases;

  RegisterBloc(this.authUseCases, this.rolesUseCases) : super(RegisterState()) {
    on<RegisterInitEvent>(_onInitEvent);
    on<RegisterNameChanged>(_onNameChanged);
    on<RegisterUsernameChanged>(_onUsernameChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterFormSubmit>(_onFormSubmit);
    on<LoadRoles>(_onLoadRoles);
    on<RoleSelected>(_onRoleSelected);
    on<RegisterFormReset>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _onInitEvent(
      RegisterInitEvent event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(formKey: formKey));
  }

  Future<void> _onNameChanged(
      RegisterNameChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
        name: BlocFormItem(
            value: event.name.value,
            error: event.name.value.isNotEmpty ? null : 'Ingresa el nombre'),
        formKey: formKey));
  }

  Future<void> _onUsernameChanged(
      RegisterUsernameChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
        username: BlocFormItem(
            value: event.username.value,
            error: event.username.value.isNotEmpty
                ? null
                : 'Ingresa el nombre de usuario'),
        formKey: formKey));
  }

  Future<void> _onPasswordChanged(
      RegisterPasswordChanged event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
        password: BlocFormItem(
            value: event.password.value,
            error: event.password.value.isNotEmpty &&
                    event.password.value.length >= 6
                ? null
                : 'Ingresa el password'),
        formKey: formKey));
  }

  Future<void> _onFormSubmit(
      RegisterFormSubmit event, Emitter<RegisterState> emit) async {
    emit(
      state.copyWith(response: Loading(), formKey: formKey),
    );
    Resource response = await authUseCases.register.run(state.toUser());
    emit(state.copyWith(response: response, formKey: formKey));
  }

  Future<void> _onFormReset(
      RegisterFormReset event, Emitter<RegisterState> emit) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onLoadRoles(
      LoadRoles event, Emitter<RegisterState> emit) async {
    try {
      var result = await rolesUseCases.getRoles.run();
      if (result is Success<List<Role>>) {
        List<Role> roles = result.data; // Extracción de la lista de roles
        emit(state.copyWith(roles: roles));
      } else {
        emit(state.copyWith(roles: []));
      }
    } catch (e) {
      emit(state
          .copyWith(roles: [])); // En caso de error, se emite una lista vacía
    }
  }

  Future<void> _onRoleSelected(
      RoleSelected event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
        roleId: BlocFormItem(
            value: event.roleId.value,
            error: event.roleId.value.isNotEmpty ? null : 'Selecciona un rol'),
        formKey: formKey));
  }
}
