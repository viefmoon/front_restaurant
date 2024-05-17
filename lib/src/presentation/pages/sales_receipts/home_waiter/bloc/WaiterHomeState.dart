import 'package:equatable/equatable.dart';

class WaiterHomeState extends Equatable {
  final int pageIndex;
  final String? name;
  final String? role;

  const WaiterHomeState({this.pageIndex = 0, this.name, this.role});

  WaiterHomeState copyWith({int? pageIndex, String? name, String? role}) {
    return WaiterHomeState(
      pageIndex: pageIndex ?? this.pageIndex,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [pageIndex];
}
