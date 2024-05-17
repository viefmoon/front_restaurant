import 'package:restaurante/src/presentation/pages/preparation/pizza/home/bloc/PizzaHomeState.dart';
import 'package:equatable/equatable.dart';

abstract class PizzaHomeEvent extends Equatable {
  const PizzaHomeEvent();
  @override
  List<Object?> get props => [];
}

class PizzaChangeDrawerPage extends PizzaHomeEvent {
  final int pageIndex;
  const PizzaChangeDrawerPage({required this.pageIndex});
  @override
  List<Object?> get props => [pageIndex];
}

class LoadUser extends PizzaHomeEvent {
  const LoadUser();
}

class InitEvent extends PizzaHomeEvent {
  const InitEvent();
}

class Logout extends PizzaHomeEvent {
  const Logout();
}

class ChangeOrderFilterType extends PizzaHomeEvent {
  final OrderFilterType filterType;

  const ChangeOrderFilterType(this.filterType);

  @override
  List<Object> get props => [filterType];
}

class SynchronizeOrders extends PizzaHomeEvent {
  const SynchronizeOrders();

  @override
  List<Object> get props => [];
}
