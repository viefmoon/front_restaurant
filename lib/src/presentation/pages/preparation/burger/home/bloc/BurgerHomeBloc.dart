import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/presentation/pages/preparation/burger/home/bloc/BurgerHomeEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/burger/home/bloc/BurgerHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BurgerHomeBloc extends Bloc<BurgerHomeEvent, BurgerHomeState> {
  AuthUseCases authUseCases;

  BurgerHomeBloc(this.authUseCases) : super(BurgerHomeState()) {
    on<BurgerChangeDrawerPage>(_onBurgerChangeDrawerPage);
    on<LoadUser>(_onLoadUser);
    on<Logout>(_onLogout);
    on<InitEvent>(_onInitEvent);
    on<ChangeOrderFilterType>(_onChangeOrderFilterType);
  }

  Future<void> _onInitEvent(
      InitEvent event, Emitter<BurgerHomeState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    if (authResponse != null) {
      emit(state.copyWith(
          name: authResponse.user.name,
          role: authResponse.user.roles?.first.name));
    }
  }

  Future<void> _onBurgerChangeDrawerPage(
      BurgerChangeDrawerPage event, Emitter<BurgerHomeState> emit) async {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onLogout(Logout event, Emitter<BurgerHomeState> emit) async {
    await authUseCases.logout.run();
  }

  Future<void> _onLoadUser(
      LoadUser event, Emitter<BurgerHomeState> emit) async {
    var userSession = await authUseCases.getUserSession.run();
    if (userSession != null) {
      emit(state.copyWith(name: userSession.user?.name ?? ''));
    }
  }

  void _onChangeOrderFilterType(
      ChangeOrderFilterType event, Emitter<BurgerHomeState> emit) {
    emit(state.copyWith(filterType: event.filterType));
  }
}
