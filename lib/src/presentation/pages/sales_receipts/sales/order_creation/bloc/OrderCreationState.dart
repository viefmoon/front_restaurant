import 'package:restaurante/src/domain/models/Category.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/Subcategory.dart';
import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/models/Area.dart';
import 'package:restaurante/src/domain/models/Table.dart' as TableModel;
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:flutter/material.dart';

enum OrderCreationStep {
  orderTypeSelection,
  phoneNumberInput,
  tableSelection,
  productSelection,
  orderSummary
}

class OrderCreationState extends Equatable {
  final OrderType? selectedOrderType;
  final String? phoneNumber;
  final List<Area>? areas;
  final List<TableModel.Table>? tables;
  final int? selectedAreaId;
  final String? selectedAreaName;
  final int? selectedTableId;
  final int? selectedTableNumber;
  final List<Category>? categories;
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final List<Subcategory>? filteredSubcategories;
  final List<Product>? filteredProducts;
  final List<OrderItem>? orderItems;
  final String? deliveryAddress;
  final String? customerName;
  final String? comments;
  final TimeOfDay? scheduledDeliveryTime;
  final double? totalCost;
  final Resource? response;
  final OrderCreationStep? step;
  final bool? isTimePickerEnabled;
  final List<OrderAdjustment>? orderAdjustments;
  final bool isTemporaryTableEnabled;
  final String? temporaryIdentifier;

  const OrderCreationState({
    this.selectedOrderType,
    this.phoneNumber,
    this.areas,
    this.tables,
    this.selectedAreaId,
    this.selectedAreaName,
    this.selectedTableId,
    this.selectedTableNumber,
    this.categories,
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    this.filteredSubcategories,
    this.filteredProducts,
    this.orderItems,
    this.deliveryAddress,
    this.customerName,
    this.comments,
    this.scheduledDeliveryTime,
    this.totalCost,
    this.response,
    this.step = OrderCreationStep.orderTypeSelection,
    this.isTimePickerEnabled = false,
    this.orderAdjustments,
    this.isTemporaryTableEnabled = false,
    this.temporaryIdentifier,
  });

  OrderCreationState copyWith({
    OrderType? selectedOrderType,
    String? phoneNumber,
    List<Area>? areas,
    List<TableModel.Table>? tables,
    int? selectedAreaId,
    String? selectedAreaName,
    int? selectedTableId,
    int? selectedTableNumber,
    List<Category>? categories,
    int? selectedCategoryId,
    int? selectedSubcategoryId,
    List<Subcategory>? filteredSubcategories,
    List<Product>? filteredProducts,
    List<OrderItem>? orderItems,
    String? deliveryAddress,
    String? customerName,
    String? comments,
    TimeOfDay? scheduledDeliveryTime,
    double? totalCost,
    Resource? response,
    OrderCreationStep? step,
    bool? isTimePickerEnabled,
    List<OrderAdjustment>? orderAdjustments,
    bool? isTemporaryTableEnabled,
    String? temporaryIdentifier,
  }) {
    return OrderCreationState(
      selectedOrderType: selectedOrderType ?? this.selectedOrderType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      areas: areas ?? this.areas,
      tables: tables ?? this.tables,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedAreaName: selectedAreaName ?? this.selectedAreaName,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      selectedTableNumber: selectedTableNumber ?? this.selectedTableNumber,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubcategoryId:
          selectedSubcategoryId ?? this.selectedSubcategoryId,
      filteredSubcategories:
          filteredSubcategories ?? this.filteredSubcategories,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      orderItems: orderItems ?? this.orderItems,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      comments: comments ?? this.comments,
      scheduledDeliveryTime:
          scheduledDeliveryTime ?? this.scheduledDeliveryTime,
      totalCost: totalCost ?? this.totalCost,
      response: response ?? this.response,
      step: step ?? this.step,
      isTimePickerEnabled: isTimePickerEnabled ?? this.isTimePickerEnabled,
      orderAdjustments: orderAdjustments ?? this.orderAdjustments,
      isTemporaryTableEnabled:
          isTemporaryTableEnabled ?? this.isTemporaryTableEnabled,
      temporaryIdentifier: temporaryIdentifier ?? this.temporaryIdentifier,
    );
  }

  @override
  List<Object?> get props => [
        selectedOrderType,
        phoneNumber,
        areas,
        tables,
        selectedAreaId,
        selectedAreaName,
        selectedTableId,
        selectedTableNumber,
        categories,
        selectedCategoryId,
        selectedSubcategoryId,
        filteredSubcategories,
        filteredProducts,
        orderItems,
        deliveryAddress,
        customerName,
        comments,
        scheduledDeliveryTime,
        totalCost,
        response,
        step,
        isTimePickerEnabled,
        orderAdjustments,
        isTemporaryTableEnabled,
        temporaryIdentifier,
      ];
}
