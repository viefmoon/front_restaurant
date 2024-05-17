import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/home/bloc/PizzaHomeEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/home/bloc/PizzaHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PizzaHomeBloc extends Bloc<PizzaHomeEvent, PizzaHomeState> {
  AuthUseCases authUseCases;

  PizzaHomeBloc(this.authUseCases) : super(PizzaHomeState()) {
    on<PizzaChangeDrawerPage>(_onPizzaChangeDrawerPage);
    on<LoadUser>(_onLoadUser);
    on<Logout>(_onLogout);
    on<InitEvent>(_onInitEvent);
    on<ChangeOrderFilterType>(_onChangeOrderFilterType);
  }

  Future<void> _onInitEvent(
      InitEvent event, Emitter<PizzaHomeState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    if (authResponse != null) {
      emit(state.copyWith(
          name: authResponse.user.name,
          role: authResponse.user.roles?.first.name));
    }
  }

  Future<void> _onPizzaChangeDrawerPage(
      PizzaChangeDrawerPage event, Emitter<PizzaHomeState> emit) async {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onLogout(Logout event, Emitter<PizzaHomeState> emit) async {
    await authUseCases.logout.run();
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<PizzaHomeState> emit) async {
    var userSession = await authUseCases.getUserSession.run();
    if (userSession != null) {
      emit(state.copyWith(name: userSession.user?.name ?? ''));
    }
  }

  void _onChangeOrderFilterType(
      ChangeOrderFilterType event, Emitter<PizzaHomeState> emit) {
    emit(state.copyWith(filterType: event.filterType));
  }
}
