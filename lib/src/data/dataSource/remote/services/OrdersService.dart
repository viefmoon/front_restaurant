import 'dart:convert';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderPrint.dart';
import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:http/http.dart' as http;
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurante/src/domain/models/OrderItemSummary.dart'; // Asegúrate de definir este modelo

class OrdersService {
  Future<Resource<Order>> createOrder(Order order) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(order.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Order createdOrder = Order.fromJson(json.decode(response.body));
        return Success<Order>(createdOrder);
      } else {
        return Error<Order>("Error al crear la orden: ${response.body}");
      }
    } catch (e) {
      return Error<Order>(e.toString());
    }
  }

  Future<Resource<List<Order>>> getOpenOrders() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/open');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = (json.decode(response.body) as List<dynamic>);
        List<Order> orders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(orders);
      } else {
        return Error("Error al obtener las órdenes abiertas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<Order>>> getClosedOrders() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/closed');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Order> orders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(orders);
      } else {
        return Error("Error al obtener las órdenes cerradas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<Order>>> getDeliveryOrders() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/delivery');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Order> orders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(orders);
      } else {
        return Error(
            "Error al obtener las órdenes de entrega: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<Order>>> getPrintedOrders() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/with-prints');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Order> orders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(orders);
      } else {
        return Error("Error al obtener las órdenes impresas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> getOrderForUpdate(int orderId) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/$orderId');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Order order = Order.fromJson(json.decode(response.body));
        return Success(order);
      } else {
        return Error(
            "Error al obtener la orden para actualizar: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> updateOrder(Order order) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();

      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user');

      // Deserializar userData desde JSON
      final userData = json.decode(userDataString!);
      final userName = userData['user']['name'];

      // Incluir el nombre del usuario como parámetro de consulta en la URL
      Uri url =
          Uri.http(apiEcommerce, '/orders/${order.id}', {'userName': userName});

      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(order.toJson()),
      );
      if (response.statusCode == 200) {
        Order updatedOrder = Order.fromJson(json.decode(response.body));
        return Success(updatedOrder);
      } else {
        return Error("Error al actualizar la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> updateOrderStatus(Order order) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/${order.id}/status');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(order.toJson()),
      );
      if (response.statusCode == 200) {
        Order updatedOrder = Order.fromJson(json.decode(response.body));
        return Success(updatedOrder);
      } else {
        return Error(
            "Error al actualizar el estado de la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<OrderItem>> updateOrderItemStatus(OrderItem orderItem) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url =
          Uri.http(apiEcommerce, '/orders/orderitems/${orderItem.id}/status');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(orderItem.toJson()),
      );
      if (response.statusCode == 200) {
        OrderItem updatedOrderItem =
            OrderItem.fromJson(json.decode(response.body));
        return Success(updatedOrderItem);
      } else {
        return Error(
            "Error al actualizar el estado del ítem de la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<void>> synchronizeData() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/synchronize');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return Success(
            null); // No hay objeto de respuesta específico, así que devolvemos null con Success.
      } else {
        return Error("Error al sincronizar los datos: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<OrderItemSummary>>> findOrderItemsWithCounts(
      {List<String>? subcategories, int? ordersLimit}) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Map<String, dynamic> queryParams = {};
      if (subcategories != null && subcategories.isNotEmpty) {
        queryParams['subcategories'] = subcategories.join(',');
      }
      if (ordersLimit != null) {
        queryParams['ordersLimit'] = ordersLimit.toString();
      }
      Uri url = Uri.http(apiEcommerce, '/orders/items/counts', queryParams);

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<OrderItemSummary> summaries = data
            .map((itemJson) => OrderItemSummary.fromJson(itemJson))
            .toList();
        return Success(summaries);
      } else {
        return Error(
            "Error al obtener el resumen de los ítems de la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> registerPayment(int orderId, double amount) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/$orderId/payment');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"amount": amount}),
      );
      if (response.statusCode == 200) {
        Order updatedOrder = Order.fromJson(json.decode(response.body));
        return Success(updatedOrder);
      } else {
        return Error("Error al registrar el pago: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> completeOrder(int orderId) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/$orderId/complete');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Order completedOrder = Order.fromJson(json.decode(response.body));
        return Success(completedOrder);
      } else {
        return Error("Error al completar la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<Order>>> completeMultipleOrders(
      List<int> orderIds) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/complete-multiple');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(orderIds),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Order> completedOrders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(completedOrders);
      } else {
        return Error("Error al completar las órdenes: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<List<Order>>> revertMultipleOrdersToPrepared(
      List<int> orderIds) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/revert-prepared-multiple');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(orderIds),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Order> revertedOrders =
            data.map((orderJson) => Order.fromJson(orderJson)).toList();
        return Success(revertedOrders);
      } else {
        return Error(
            "Error al revertir las órdenes a preparadas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<Order>> cancelOrder(int orderId) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/$orderId/cancel');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Order canceledOrder = Order.fromJson(json.decode(response.body));
        return Success(canceledOrder);
      } else {
        return Error("Error al cancelar la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<void>> markOrdersAsInDelivery(List<Order> orders) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/delivery/mark-in-delivery');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(orders.map((order) => order.toJson()).toList()),
      );
      if (response.statusCode == 200) {
        return Success(
            null); // No hay objeto de respuesta específico, así que devolvemos null con Success.
      } else {
        return Error(
            "Error al marcar las órdenes como en reparto: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<void>> resetDatabase() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, 'orders/reset-database');
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return Success(
            null); // No hay objeto de respuesta específico, así que devolvemos null con Success.
      } else {
        return Error("Error al resetear la base de datos: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<OrderPrint>> registerTicketPrint(
      int orderId, String printedBy) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/$orderId/print');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "printedBy": printedBy,
          "printTime": DateTime.now().toIso8601String()
        }),
      );
      if (response.statusCode == 200) {
        OrderPrint orderPrint = OrderPrint.fromJson(json.decode(response.body));
        return Success(orderPrint);
      } else {
        return Error(
            "Error al registrar la impresión del ticket: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<SalesReport>> getSalesReport() async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce, '/orders/sales-report');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SalesReport report = SalesReport.fromJson(data);
        return Success(report);
      } else {
        return Error("Error al obtener el informe de ventas: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<Resource<OrderItem>> updateOrderItemPreparationAdvanceStatus(
      int orderId, int orderItemId, bool isBeingPreparedInAdvance) async {
    try {
      String apiEcommerce = await ApiConfig.getApiEcommerce();
      Uri url = Uri.http(apiEcommerce,
          '/orders/$orderId/order-items/$orderItemId/preparation-advance-status');
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body:
            json.encode({"isBeingPreparedInAdvance": isBeingPreparedInAdvance}),
      );
      if (response.statusCode == 200) {
        OrderItem updatedOrderItem =
            OrderItem.fromJson(json.decode(response.body));
        return Success(updatedOrderItem);
      } else {
        return Error(
            "Error al actualizar el estado de preparación por adelantado del ítem de la orden: ${response.body}");
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
