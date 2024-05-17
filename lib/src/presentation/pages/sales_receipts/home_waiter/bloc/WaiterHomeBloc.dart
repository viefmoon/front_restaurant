import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home_waiter/bloc/WaiterHomeEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home_waiter/bloc/WaiterHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaiterHomeBloc extends Bloc<WaiterHomeEvent, WaiterHomeState> {
  AuthUseCases authUseCases;

  WaiterHomeBloc(this.authUseCases) : super(WaiterHomeState()) {
    on<WaiterChangeDrawerPage>(_onWaiterChangeDrawerPage);
    on<LoadUser>(_onLoadUser);
    on<Logout>(_onLogout);
    on<InitEvent>(_onInitEvent);
  }

  Future<void> _onInitEvent(
      InitEvent event, Emitter<WaiterHomeState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    if (authResponse != null) {
      emit(state.copyWith(
          name: authResponse.user.name,
          role: authResponse.user.roles?.first.name));
    }
  }

  Future<void> _onWaiterChangeDrawerPage(
      WaiterChangeDrawerPage event, Emitter<WaiterHomeState> emit) async {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onLogout(Logout event, Emitter<WaiterHomeState> emit) async {
    await authUseCases.logout.run();
  }

  Future<void> _onLoadUser(
      LoadUser event, Emitter<WaiterHomeState> emit) async {
    var userSession = await authUseCases.getUserSession.run();
    if (userSession != null) {
      emit(state.copyWith(name: userSession.user?.name ?? ''));
    }
  }
}
