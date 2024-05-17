import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/bloc/SalesReportEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/bloc/SalesReportState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  final OrdersUseCases ordersUseCases;

  SalesReportBloc({required this.ordersUseCases}) : super(SalesReportState()) {
    on<LoadSalesReport>(_onLoadSalesReport);
  }

  Future<void> _onLoadSalesReport(
      LoadSalesReport event, Emitter<SalesReportState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<SalesReport> response = await ordersUseCases.getSalesReport.run();
    if (response is Success<SalesReport>) {
      SalesReport salesReport = response.data;
      emit(state.copyWith(
          salesReport: salesReport, response: Success(salesReport)));
    } else {
      emit(state.copyWith(
          salesReport: null,
          response: Error('Error al obtener el informe de ventas')));
    }
  }
}
