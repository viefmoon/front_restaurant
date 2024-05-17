import 'package:equatable/equatable.dart';

abstract class SalesReportEvent extends Equatable {
  const SalesReportEvent();

  @override
  List<Object> get props => [];
}

class LoadSalesReport extends SalesReportEvent {
  const LoadSalesReport();
}
