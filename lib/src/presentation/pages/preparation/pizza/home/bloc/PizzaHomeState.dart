import 'package:equatable/equatable.dart';

enum OrderFilterType { all, delivery, dineIn, pickUpWait }

class PizzaHomeState extends Equatable {
  final int pageIndex;
  final String? name;
  final String? role;
  final OrderFilterType? orderFilterType;

  const PizzaHomeState(
      {this.pageIndex = 0,
      this.name,
      this.role,
      this.orderFilterType = OrderFilterType.all});

  PizzaHomeState copyWith(
      {int? pageIndex,
      String? name,
      String? role,
      OrderFilterType? filterType}) {
    return PizzaHomeState(
      pageIndex: pageIndex ?? this.pageIndex,
      name: name ?? this.name,
      role: role ?? this.role,
      orderFilterType: orderFilterType ?? this.orderFilterType,
    );
  }

  @override
  List<Object?> get props => [pageIndex, name, role, orderFilterType];
}
