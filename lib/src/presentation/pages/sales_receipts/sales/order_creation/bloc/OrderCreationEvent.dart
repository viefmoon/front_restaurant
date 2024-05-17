import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class OrderCreationEvent extends Equatable {
  const OrderCreationEvent();
  @override
  List<Object> get props => [];
}

class OrderTypeSelected extends OrderCreationEvent {
  final OrderType selectedOrderType;

  const OrderTypeSelected({required this.selectedOrderType});
}

class ResetTableSelection extends OrderCreationEvent {
  const ResetTableSelection();

  @override
  List<Object> get props => [];
}

class UpdateOrderItem extends OrderCreationEvent {
  final OrderItem orderItem;

  const UpdateOrderItem({required this.orderItem});

  @override
  List<Object> get props => [orderItem];
}

class PhoneNumberEntered extends OrderCreationEvent {
  final String phoneNumber;

  const PhoneNumberEntered({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class DeliveryAddressEntered extends OrderCreationEvent {
  final String deliveryAddress;

  const DeliveryAddressEntered({required this.deliveryAddress});

  @override
  List<Object> get props => [deliveryAddress];
}

class CustomerNameEntered extends OrderCreationEvent {
  final String customerName;

  const CustomerNameEntered({required this.customerName});

  @override
  List<Object> get props => [customerName];
}

class OrderCommentsEntered extends OrderCreationEvent {
  final String comments;

  const OrderCommentsEntered({required this.comments});

  @override
  List<Object> get props => [comments];
}

class TimePickerEnabled extends OrderCreationEvent {
  final bool isTimePickerEnabled;

  const TimePickerEnabled({required this.isTimePickerEnabled});

  @override
  List<Object> get props => [isTimePickerEnabled];
}

class TimeSelected extends OrderCreationEvent {
  final TimeOfDay time;

  const TimeSelected({required this.time});

  @override
  List<Object> get props => [time];
}

class LoadAreas extends OrderCreationEvent {
  const LoadAreas();
}

class ResetOrder extends OrderCreationEvent {
  const ResetOrder();
}

class LoadTables extends OrderCreationEvent {
  final int areaId;
  const LoadTables({required this.areaId});
  @override
  List<Object> get props => [areaId];
}

class AreaSelected extends OrderCreationEvent {
  final int areaId;
  const AreaSelected({required this.areaId});
  @override
  List<Object> get props => [areaId];
}

class TableSelected extends OrderCreationEvent {
  final int tableId;
  const TableSelected({required this.tableId});
  @override
  List<Object> get props => [tableId];
}

class LoadCategoriesWithProducts extends OrderCreationEvent {
  const LoadCategoriesWithProducts();
}

class CategorySelected extends OrderCreationEvent {
  final int categoryId;
  const CategorySelected({required this.categoryId});
  @override
  List<Object> get props => [categoryId];
}

class SubcategorySelected extends OrderCreationEvent {
  final int subcategoryId;
  const SubcategorySelected({required this.subcategoryId});
  @override
  List<Object> get props => [subcategoryId];
}

class AddProductToOrder extends OrderCreationEvent {
  final Product product;
  const AddProductToOrder({required this.product});
  @override
  List<Object> get props => [product];
}

class TableSelectionContinue extends OrderCreationEvent {
  const TableSelectionContinue();
}

class ResetResponseEvent extends OrderCreationEvent {
  const ResetResponseEvent();
}

class AddOrderItem extends OrderCreationEvent {
  final OrderItem orderItem;

  const AddOrderItem({required this.orderItem});

  @override
  List<Object> get props => [orderItem];
}

class SendOrder extends OrderCreationEvent {
  const SendOrder();

  @override
  List<Object> get props => [];
}

class RemoveOrderItem extends OrderCreationEvent {
  final String tempId;

  const RemoveOrderItem({required this.tempId});

  @override
  List<Object> get props => [tempId];
}

class OrderAdjustmentAdded extends OrderCreationEvent {
  final OrderAdjustment orderAdjustment;
  const OrderAdjustmentAdded({required this.orderAdjustment});

  @override
  List<Object> get props => [orderAdjustment];
}

class OrderAdjustmentRemoved extends OrderCreationEvent {
  final OrderAdjustment orderAdjustment;

  const OrderAdjustmentRemoved({required this.orderAdjustment});

  @override
  List<Object> get props => [orderAdjustment];
}

class OrderAdjustmentUpdated extends OrderCreationEvent {
  final OrderAdjustment orderAdjustment;

  const OrderAdjustmentUpdated({required this.orderAdjustment});

  @override
  List<Object> get props => [orderAdjustment];
}

class UpdateTotalCost extends OrderCreationEvent {
  const UpdateTotalCost();
}

class ToggleTemporaryTable extends OrderCreationEvent {
  final bool isEnabled;

  const ToggleTemporaryTable(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class UpdateTemporaryIdentifier extends OrderCreationEvent {
  final String identifier;

  const UpdateTemporaryIdentifier(this.identifier);

  @override
  List<Object> get props => [identifier];
}
