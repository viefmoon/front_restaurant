import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/OrderSummaryPage.dart'; // Asegúrate de importar OrderSummaryPage
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/OrderTypeSelectionPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/PhoneNumberInputPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/ProductSelectionPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/TableSelectionPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCreationContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _customBackButton(context),
        title: BlocBuilder<OrderCreationBloc, OrderCreationState>(
          builder: (context, state) {
            // Cambia el título según el paso en el proceso de creación de la orden
            switch (state.step) {
              case OrderCreationStep.orderTypeSelection:
                return Text('Selecciona el tipo de orden',
                    style: TextStyle(fontSize: 26));
              case OrderCreationStep.phoneNumberInput:
                return Text('Ingresa tu número de teléfono',
                    style: TextStyle(fontSize: 26));
              case OrderCreationStep.tableSelection:
                return Text('Selecciona una mesa',
                    style: TextStyle(fontSize: 26));
              case OrderCreationStep.productSelection:
                if (state.selectedOrderType == OrderType.dineIn) {
                  String area = state.selectedAreaName ?? 'N/A';
                  String table = (state.selectedTableNumber != null &&
                          state.selectedTableNumber != 0)
                      ? state.selectedTableNumber.toString()
                      : (state.temporaryIdentifier ?? 'N/A');
                  return Text('$area: $table', style: TextStyle(fontSize: 26));
                } else if (state.selectedOrderType == OrderType.delivery) {
                  String phoneNumber = state.phoneNumber ?? 'N/A';
                  return Text('Telefono: $phoneNumber',
                      style: TextStyle(fontSize: 26));
                }
                break;
              case OrderCreationStep.orderSummary:
                return Text('Resumen de la orden',
                    style: TextStyle(fontSize: 26));
              default:
                // Maneja el caso null y cualquier otro no contemplado
                return Text('Default', style: TextStyle(fontSize: 26));
            }
            // Retorno por defecto para manejar cualquier caso no contemplado
            return Text('Pasan/Esperan', style: TextStyle(fontSize: 26));
          },
        ),
        actions: <Widget>[
          BlocBuilder<OrderCreationBloc, OrderCreationState>(
            builder: (context, state) {
              if (state.step == OrderCreationStep.productSelection) {
                // Solo muestra el botón en el paso de selección de productos
                return IconButton(
                  icon: Icon(Icons.shopping_cart,
                      size: 40), // Tamaño del icono aumentado
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderSummaryPage()),
                    );
                  },
                );
              } else {
                return Container(); // No muestra ningún botón en otros pasos
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderCreationBloc, OrderCreationState>(
        builder: (context, state) {
          // Lógica para mostrar el contenido basado en el estado actual, como antes
          switch (state.step) {
            case OrderCreationStep.orderTypeSelection:
              return OrderTypeSelectionPage();
            case OrderCreationStep.phoneNumberInput:
              return PhoneNumberInputPage();
            case OrderCreationStep.tableSelection:
              return TableSelectionPage();
            case OrderCreationStep.productSelection:
              return ProductSelectionPage();
            case OrderCreationStep.orderSummary:
              return OrderSummaryPage();
            default:
              return OrderTypeSelectionPage();
          }
        },
      ),
    );
  }

  Widget _customBackButton(BuildContext context) {
    return BlocBuilder<OrderCreationBloc, OrderCreationState>(
      builder: (context, state) {
        if (state.step == OrderCreationStep.productSelection) {
          return IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _showExitConfirmationDialog(context),
          );
        } else {
          // Para cualquier otro paso que no sea la selección de productos, muestra el botón de retroceso que simplemente hace pop.
          return IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          );
        }
      },
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final bool? shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text(
            '¿Estás seguro de que deseas salir? Los cambios no guardados se perderán.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Cierra el diálogo
              // Resetear el estado de la orden en creación
              BlocProvider.of<OrderCreationBloc>(context).add(ResetOrder());
              // Obtener la sesión del usuario
              AuthResponse? userSession =
                  await BlocProvider.of<OrderCreationBloc>(context)
                      .authUseCases
                      .getUserSession
                      .run();
              String? userRole = userSession?.user.roles?.isNotEmpty == true
                  ? userSession?.user.roles!.first.name
                  : null;

              // Decidir a qué página navegar basado en el rol del usuario
              if (userRole == 'Administrador') {
                Navigator.pushNamed(context, 'salesHome');
              } else if (userRole == 'Mesero') {
                Navigator.pushNamed(context, 'waiterHome');
              } else {
                Navigator.popUntil(context, ModalRoute.withName('salesHome'));
              }
            },
            child: Text('Salir'),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      // Esta línea se ha movido dentro del TextButton para asegurar que se ejecute después de obtener la sesión del usuario
    }
  }
}
