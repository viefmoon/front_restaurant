import 'package:restaurante/src/domain/useCases/orders/CancelOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CompleteMultipleOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CompleteOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CreateOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/FindOrderItemsWithCounts.dart';
import 'package:restaurante/src/domain/useCases/orders/GetClosedOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetDeliveryOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetOpenOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetOrderForUpdateUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetPrintedOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetSalesReportUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/MarkOrdersAsInDeliveryUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/RegisterPaymentUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/RegisterTicketPrintUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/ResetDatabaseUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/RevertMultipleOrdersUseCase%20copy.dart';
import 'package:restaurante/src/domain/useCases/orders/SynchronizeDataUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderItemPreparationAdvanceStatus.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderItemStatusUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderStatusUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderUseCase.dart';

class OrdersUseCases {
  CreateOrderUseCase createOrder;
  GetOpenOrdersUseCase getOpenOrders;
  GetClosedOrdersUseCase getClosedOrders;
  GetOrderForUpdateUseCase getOrderForUpdate;
  UpdateOrderUseCase updateOrder;
  UpdateOrderStatusUseCase updateOrderStatus;
  UpdateOrderItemStatusUseCase updateOrderItemStatus;
  SynchronizeDataUseCase synchronizeData;
  FindOrderItemsWithCountsUseCase findOrderItemsWithCounts;
  RegisterPaymentUseCase registerPayment;
  CompleteOrderUseCase completeOrder;
  CancelOrderUseCase cancelOrder;
  GetDeliveryOrdersUseCase getDeliveryOrders;
  MarkOrdersAsInDeliveryUseCase markOrdersAsInDelivery;
  ResetDatabaseUseCase resetDatabase;
  GetPrintedOrdersUseCase getPrintedOrders;
  RegisterTicketPrintUseCase registerTicketPrint;
  CompleteMultipleOrdersUseCase completeMultipleOrders;
  RevertMultipleOrdersUseCase revertMultipleOrders;
  GetSalesReportUseCase getSalesReport;
  UpdateOrderItemPreparationAdvanceStatusUseCase
      updateOrderItemPreparationAdvanceStatus;

  OrdersUseCases({
    required this.createOrder,
    required this.getOpenOrders,
    required this.getClosedOrders,
    required this.updateOrder,
    required this.getOrderForUpdate,
    required this.updateOrderStatus,
    required this.updateOrderItemStatus,
    required this.synchronizeData,
    required this.findOrderItemsWithCounts,
    required this.registerPayment,
    required this.completeOrder,
    required this.cancelOrder,
    required this.getDeliveryOrders,
    required this.markOrdersAsInDelivery,
    required this.resetDatabase,
    required this.getPrintedOrders,
    required this.registerTicketPrint,
    required this.completeMultipleOrders,
    required this.revertMultipleOrders,
    required this.getSalesReport,
    required this.updateOrderItemPreparationAdvanceStatus,
  });
}
