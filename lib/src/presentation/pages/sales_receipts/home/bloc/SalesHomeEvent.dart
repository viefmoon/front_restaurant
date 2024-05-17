import 'package:equatable/equatable.dart';

abstract class SalesHomeEvent extends Equatable {
  const SalesHomeEvent();
  @override
  List<Object?> get props => [];
}

class SalesChangeDrawerPage extends SalesHomeEvent {
  final int pageIndex;
  const SalesChangeDrawerPage({required this.pageIndex});
  @override
  List<Object?> get props => [pageIndex];
}

class LoadUser extends SalesHomeEvent {
  const LoadUser();
}

class InitEvent extends SalesHomeEvent {
  const InitEvent();
}

class Logout extends SalesHomeEvent {
  const Logout();
}
