import 'package:restaurante/src/data/dataSource/remote/services/OrdersService.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderItemSummary.dart';
import 'package:restaurante/src/domain/models/OrderPrint.dart';
import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersService ordersService;

  OrdersRepositoryImpl(this.ordersService);

  @override
  Future<Resource<Order>> createOrder(Order order) async {
    return ordersService.createOrder(order);
  }

  @override
  Future<Resource<List<Order>>> getOpenOrders() async {
    return ordersService.getOpenOrders();
  }

  @override
  Future<Resource<List<Order>>> getClosedOrders() async {
    return ordersService.getClosedOrders();
  }

  @override
  Future<Resource<List<Order>>> getDeliveryOrders() async {
    return ordersService.getDeliveryOrders();
  }

  @override
  Future<Resource<void>> markOrdersAsInDelivery(List<Order> orders) async {
    return ordersService.markOrdersAsInDelivery(orders);
  }

  @override
  Future<Resource<Order>> getOrderForUpdate(int orderId) {
    return ordersService.getOrderForUpdate(orderId);
  }

  @override
  Future<Resource<Order>> updateOrderStatus(Order order) {
    return ordersService.updateOrderStatus(order);
  }

  @override
  Future<Resource<OrderItem>> updateOrderItemStatus(OrderItem orderItem) {
    return ordersService.updateOrderItemStatus(orderItem);
  }

  @override
  Future<Resource<Order>> updateOrder(Order order) {
    return ordersService.updateOrder(order);
  }

  @override
  Future<Resource<void>> synchronizeData() async {
    return ordersService.synchronizeData();
  }

  @override
  Future<Resource<List<OrderItemSummary>>> findOrderItemsWithCounts(
      {List<String>? subcategories, int? ordersLimit}) {
    return ordersService.findOrderItemsWithCounts(
        subcategories: subcategories, ordersLimit: ordersLimit);
  }

  @override
  Future<Resource<Order>> registerPayment(int orderId, double amount) {
    return ordersService.registerPayment(orderId, amount);
  }

  @override
  Future<Resource<Order>> completeOrder(int orderId) {
    return ordersService.completeOrder(orderId);
  }

  @override
  Future<Resource<List<Order>>> completeMultipleOrders(List<int> orderIds) {
    return ordersService.completeMultipleOrders(orderIds);
  }

  @override
  Future<Resource<List<Order>>> revertMultipleOrdersToPrepared(
      List<int> orderIds) {
    return ordersService.revertMultipleOrdersToPrepared(orderIds);
  }

  @override
  Future<Resource<Order>> cancelOrder(int orderId) {
    return ordersService.cancelOrder(orderId);
  }

  Future<Resource<void>> resetDatabase() async {
    return ordersService.resetDatabase();
  }

  @override
  Future<Resource<List<Order>>> getPrintedOrders() async {
    return ordersService.getPrintedOrders();
  }

  @override
  Future<Resource<OrderPrint>> registerTicketPrint(
      int orderId, String printedBy) {
    return ordersService.registerTicketPrint(orderId, printedBy);
  }

  @override
  Future<Resource<SalesReport>> getSalesReport() {
    return ordersService.getSalesReport();
  }

  @override
  Future<Resource<OrderItem>> updateOrderItemPreparationAdvanceStatus(
      int orderId, int orderItemId, bool isBeingPreparedInAdvance) {
    return ordersService.updateOrderItemPreparationAdvanceStatus(
        orderId, orderItemId, isBeingPreparedInAdvance);
  }
}
