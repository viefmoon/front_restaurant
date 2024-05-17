import 'package:restaurante/src/presentation/pages/preparation/burger/home/bloc/BurgerHomeState.dart';
import 'package:equatable/equatable.dart';

abstract class BurgerHomeEvent extends Equatable {
  const BurgerHomeEvent();
  @override
  List<Object?> get props => [];
}

class BurgerChangeDrawerPage extends BurgerHomeEvent {
  final int pageIndex;
  const BurgerChangeDrawerPage({required this.pageIndex});
  @override
  List<Object?> get props => [pageIndex];
}

class LoadUser extends BurgerHomeEvent {
  const LoadUser();
}

class InitEvent extends BurgerHomeEvent {
  const InitEvent();
}

class Logout extends BurgerHomeEvent {
  const Logout();
}

class ChangeOrderFilterType extends BurgerHomeEvent {
  final OrderFilterType filterType;

  const ChangeOrderFilterType(this.filterType);

  @override
  List<Object> get props => [filterType];
}

class SynchronizeOrders extends BurgerHomeEvent {
  const SynchronizeOrders();

  @override
  List<Object> get props => [];
}
