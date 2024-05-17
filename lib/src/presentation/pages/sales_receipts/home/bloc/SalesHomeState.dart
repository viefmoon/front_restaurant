import 'package:equatable/equatable.dart';

class SalesHomeState extends Equatable {
  final int pageIndex;
  final String? name;
  final String? role;

  const SalesHomeState({this.pageIndex = 0, this.name, this.role});

  SalesHomeState copyWith({int? pageIndex, String? name, String? role}) {
    return SalesHomeState(
      pageIndex: pageIndex ?? this.pageIndex,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [pageIndex];
}
