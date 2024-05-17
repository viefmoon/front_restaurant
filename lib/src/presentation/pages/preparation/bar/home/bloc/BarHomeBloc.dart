import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/home/bloc/BarHomeEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/home/bloc/BarHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BarHomeBloc extends Bloc<BarHomeEvent, BarHomeState> {
  AuthUseCases authUseCases;

  BarHomeBloc(this.authUseCases) : super(BarHomeState()) {
    on<BarChangeDrawerPage>(_onBarChangeDrawerPage);
    on<LoadUser>(_onLoadUser);
    on<Logout>(_onLogout);
    on<InitEvent>(_onInitEvent);
    on<ChangeOrderFilterType>(_onChangeOrderFilterType);
  }

  Future<void> _onInitEvent(InitEvent event, Emitter<BarHomeState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    if (authResponse != null) {
      emit(state.copyWith(
          name: authResponse.user.name,
          role: authResponse.user.roles?.first.name));
    }
  }

  Future<void> _onBarChangeDrawerPage(
      BarChangeDrawerPage event, Emitter<BarHomeState> emit) async {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onLogout(Logout event, Emitter<BarHomeState> emit) async {
    await authUseCases.logout.run();
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<BarHomeState> emit) async {
    var userSession = await authUseCases.getUserSession.run();
    if (userSession != null) {
      emit(state.copyWith(name: userSession.user?.name ?? ''));
    }
  }

  void _onChangeOrderFilterType(
      ChangeOrderFilterType event, Emitter<BarHomeState> emit) {
    emit(state.copyWith(filterType: event.filterType));
  }
}
