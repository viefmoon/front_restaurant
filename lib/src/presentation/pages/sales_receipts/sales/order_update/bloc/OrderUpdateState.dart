import 'package:restaurante/src/domain/models/Area.dart';
import 'package:restaurante/src/domain/models/Category.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/Subcategory.dart';
import 'package:restaurante/src/domain/models/Table.dart' as TableModel;
import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:flutter/material.dart';

class OrderUpdateState extends Equatable {
  final List<Order>? orders;
  final int? orderIdSelectedForUpdate;
  final Order? selectedOrder;
  final OrderType? selectedOrderType;
  final List<Area>? areas;
  final List<TableModel.Table>? tables;
  final int? selectedAreaId;
  final String? selectedAreaName;
  final int? selectedTableId;
  final int? selectedTableNumber;
  final String? phoneNumber;
  final String? deliveryAddress;
  final String? customerName;
  final String? comments;
  final TimeOfDay? scheduledDeliveryTime;
  final double? totalCost;
  final List<OrderItem>? orderItems;
  final Resource? response;
  final List<Category>? categories;
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final List<Subcategory>? filteredSubcategories;
  final List<Product>? filteredProducts;
  final bool? isTimePickerEnabled;
  final List<OrderAdjustment>? orderAdjustments;
  final bool isTemporaryTableEnabled;
  final String? temporaryIdentifier;

  const OrderUpdateState({
    this.orders,
    this.orderIdSelectedForUpdate,
    this.selectedOrder,
    this.selectedOrderType,
    this.areas,
    this.tables,
    this.selectedAreaId,
    this.selectedAreaName,
    this.selectedTableId,
    this.selectedTableNumber,
    this.phoneNumber,
    this.deliveryAddress,
    this.customerName,
    this.comments,
    this.scheduledDeliveryTime,
    this.totalCost,
    this.orderItems,
    this.response,
    this.categories,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    this.filteredSubcategories,
    this.filteredProducts,
    this.isTimePickerEnabled,
    this.orderAdjustments,
    this.isTemporaryTableEnabled = false,
    this.temporaryIdentifier,
  });

  OrderUpdateState copyWith({
    List<Order>? orders,
    int? orderIdSelectedForUpdate,
    Order? selectedOrder,
    OrderType? selectedOrderType,
    List<Area>? areas,
    List<TableModel.Table>? tables,
    int? selectedAreaId,
    String? selectedAreaName,
    int? selectedTableId,
    int? selectedTableNumber,
    String? phoneNumber,
    String? deliveryAddress,
    String? customerName,
    String? comments,
    TimeOfDay? scheduledDeliveryTime,
    double? totalCost,
    List<OrderItem>? orderItems,
    String? errorMessage,
    Resource? response,
    List<Category>? categories,
    int? selectedCategoryId,
    int? selectedSubcategoryId,
    List<Subcategory>? filteredSubcategories,
    List<Product>? filteredProducts,
    bool? isTimePickerEnabled,
    List<OrderAdjustment>? orderAdjustments,
    bool? isTemporaryTableEnabled,
    String? temporaryIdentifier,
  }) {
    return OrderUpdateState(
      orders: orders ?? this.orders,
      orderIdSelectedForUpdate: orderIdSelectedForUpdate ??
          this.orderIdSelectedForUpdate, // Asignar el nuevo parámetro
      selectedOrder: selectedOrder ?? this.selectedOrder,
      selectedOrderType: selectedOrderType ?? this.selectedOrderType,
      areas: areas ?? this.areas,
      tables: tables ?? this.tables,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedAreaName: selectedAreaName ?? this.selectedAreaName,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      selectedTableNumber: selectedTableNumber ?? this.selectedTableNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      comments: comments ?? this.comments,
      scheduledDeliveryTime:
          scheduledDeliveryTime ?? this.scheduledDeliveryTime,
      totalCost: totalCost ?? this.totalCost,
      orderItems: orderItems ?? this.orderItems,
      response: response ?? this.response,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubcategoryId:
          selectedSubcategoryId ?? this.selectedSubcategoryId,
      filteredSubcategories:
          filteredSubcategories ?? this.filteredSubcategories,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isTimePickerEnabled: isTimePickerEnabled ?? this.isTimePickerEnabled,
      orderAdjustments: orderAdjustments ?? this.orderAdjustments,
      isTemporaryTableEnabled:
          isTemporaryTableEnabled ?? this.isTemporaryTableEnabled,
      temporaryIdentifier: temporaryIdentifier ?? this.temporaryIdentifier,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        orderIdSelectedForUpdate, // Añadir el nuevo parámetro a props
        selectedOrder,
        selectedOrderType,
        areas,
        tables,
        selectedAreaId,
        selectedAreaName,
        selectedTableId,
        selectedTableNumber,
        phoneNumber,
        deliveryAddress,
        customerName,
        comments,
        scheduledDeliveryTime,
        totalCost,
        orderItems,
        response,
        categories,
        selectedCategoryId,
        selectedSubcategoryId,
        filteredSubcategories,
        filteredProducts,
        isTimePickerEnabled,
        orderAdjustments,
        isTemporaryTableEnabled,
        temporaryIdentifier,
      ];
}
