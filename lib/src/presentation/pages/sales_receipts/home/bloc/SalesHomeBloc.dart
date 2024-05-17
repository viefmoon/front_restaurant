import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home/bloc/SalesHomeEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home/bloc/SalesHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesHomeBloc extends Bloc<SalesHomeEvent, SalesHomeState> {
  AuthUseCases authUseCases;

  SalesHomeBloc(this.authUseCases) : super(SalesHomeState()) {
    on<SalesChangeDrawerPage>(_onSalesChangeDrawerPage);
    on<LoadUser>(_onLoadUser);
    on<Logout>(_onLogout);
    on<InitEvent>(_onInitEvent);
  }

  Future<void> _onInitEvent(
      InitEvent event, Emitter<SalesHomeState> emit) async {
    AuthResponse? authResponse = await authUseCases.getUserSession.run();
    if (authResponse != null) {
      emit(state.copyWith(
          name: authResponse.user.name,
          role: authResponse.user.roles?.first.name));
    }
  }

  Future<void> _onSalesChangeDrawerPage(
      SalesChangeDrawerPage event, Emitter<SalesHomeState> emit) async {
    emit(state.copyWith(pageIndex: event.pageIndex));
  }

  Future<void> _onLogout(Logout event, Emitter<SalesHomeState> emit) async {
    await authUseCases.logout.run();
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<SalesHomeState> emit) async {
    var userSession = await authUseCases.getUserSession.run();
    if (userSession != null) {
      emit(state.copyWith(name: userSession.user?.name ?? ''));
    }
  }
}
