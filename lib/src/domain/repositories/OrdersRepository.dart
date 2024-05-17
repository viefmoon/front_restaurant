import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderItemSummary.dart';
import 'package:restaurante/src/domain/models/OrderPrint.dart';
import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/domain/models/Order.dart';

abstract class OrdersRepository {
  Future<Resource<Order>> createOrder(Order order);
  Future<Resource<List<Order>>> getOpenOrders();
  Future<Resource<List<Order>>> getClosedOrders();
  Future<Resource<Order>> getOrderForUpdate(int orderId);
  Future<Resource<Order>> updateOrderStatus(Order order);
  Future<Resource<OrderItem>> updateOrderItemStatus(OrderItem orderItem);
  Future<Resource<OrderItem>> updateOrderItemPreparationAdvanceStatus(
      int orderId, int orderItemId, bool isBeingPreparedInAdvance);
  Future<Resource<Order>> updateOrder(Order order);
  Future<Resource<void>> synchronizeData();
  Future<Resource<List<OrderItemSummary>>> findOrderItemsWithCounts(
      {List<String>? subcategories, int? ordersLimit});
  Future<Resource<Order>> registerPayment(int orderId, double amount);
  Future<Resource<Order>> completeOrder(int orderId);
  Future<Resource<List<Order>>> completeMultipleOrders(List<int> orderIds);
  Future<Resource<List<Order>>> revertMultipleOrdersToPrepared(
      List<int> orderIds);
  Future<Resource<Order>> cancelOrder(int orderId);
  Future<Resource<List<Order>>> getDeliveryOrders();
  Future<Resource<void>> markOrdersAsInDelivery(List<Order> orders);
  Future<Resource<void>> resetDatabase();
  Future<Resource<List<Order>>> getPrintedOrders();
  Future<Resource<OrderPrint>> registerTicketPrint(
      int orderId, String printedBy);
  Future<Resource<SalesReport>> getSalesReport();
}
