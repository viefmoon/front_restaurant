import 'package:restaurante/src/presentation/pages/preparation/bar/home/bloc/BarHomeState.dart';
import 'package:equatable/equatable.dart';

abstract class BarHomeEvent extends Equatable {
  const BarHomeEvent();
  @override
  List<Object?> get props => [];
}

class BarChangeDrawerPage extends BarHomeEvent {
  final int pageIndex;
  const BarChangeDrawerPage({required this.pageIndex});
  @override
  List<Object?> get props => [pageIndex];
}

class LoadUser extends BarHomeEvent {
  const LoadUser();
}

class InitEvent extends BarHomeEvent {
  const InitEvent();
}

class Logout extends BarHomeEvent {
  const Logout();
}

class ChangeOrderFilterType extends BarHomeEvent {
  final OrderFilterType filterType;

  const ChangeOrderFilterType(this.filterType);

  @override
  List<Object> get props => [filterType];
}

class SynchronizeOrders extends BarHomeEvent {
  const SynchronizeOrders();

  @override
  List<Object> get props => [];
}
