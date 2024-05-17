import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:equatable/equatable.dart';

class SalesReportState extends Equatable {
  final SalesReport? salesReport;
  final Resource? response;

  const SalesReportState({
    this.salesReport,
    this.response,
  });

  SalesReportState copyWith({
    SalesReport? salesReport,
    Resource? response,
  }) {
    return SalesReportState(
      salesReport: salesReport ?? this.salesReport,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [salesReport, response];
}
