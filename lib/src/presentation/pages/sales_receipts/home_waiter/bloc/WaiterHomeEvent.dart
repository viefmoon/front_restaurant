import 'package:equatable/equatable.dart';

abstract class WaiterHomeEvent extends Equatable {
  const WaiterHomeEvent();
  @override
  List<Object?> get props => [];
}

class WaiterChangeDrawerPage extends WaiterHomeEvent {
  final int pageIndex;
  const WaiterChangeDrawerPage({required this.pageIndex});
  @override
  List<Object?> get props => [pageIndex];
}

class LoadUser extends WaiterHomeEvent {
  const LoadUser();
}

class InitEvent extends WaiterHomeEvent {
  const InitEvent();
}

class Logout extends WaiterHomeEvent {
  const Logout();
}
