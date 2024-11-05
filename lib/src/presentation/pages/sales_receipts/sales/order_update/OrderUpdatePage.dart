import 'dart:async';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';
import 'package:restaurante/src/domain/models/Table.dart' as RestauranteTable;
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/AddProductPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/UpdateProductPersonalizationPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateEvent.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class OrderUpdatePage extends StatefulWidget {
  const OrderUpdatePage({Key? key}) : super(key: key);

  @override
  _OrderUpdatePageState createState() => _OrderUpdatePageState();
}

final Map<OrderType, String> _orderTypeTranslations = {
  OrderType.dineIn: 'Comer Dentro',
  OrderType.delivery: 'Entrega a domicilio',
  OrderType.pickup: 'Llevar/Esperar',
};

class _OrderUpdatePageState extends State<OrderUpdatePage> {
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _customerNameController;
  late TextEditingController _commentsController;
  late TextEditingController _tempTableController;
  String? _userRole;
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: "");
    _addressController = TextEditingController(text: "");
    _customerNameController = TextEditingController(text: "");
    _commentsController = TextEditingController(text: "");
    _tempTableController = TextEditingController(text: "");
    _determineUserRole();
    // Emitir el evento para cargar las categorías al iniciar la página
    BlocProvider.of<OrderUpdateBloc>(context, listen: false)
        .add(LoadCategoriesWithProducts());
    _initSpeechToText();
  }

  Future<void> _initSpeechToText() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'notListening') {
          _speech.stop();
        }
      },
    );
    if (!available) {
      print(
          "El usuario no tiene permisos para usar el micrófono o no hay micrófono disponible.");
    }
  }

  Future<void> _determineUserRole() async {
    _userRole = await _getUserRole(context);
    setState(
        () {}); // Actualiza la UI una vez que el rol del usuario está disponible
  }

  Future<String?> _getUserRole(BuildContext context) async {
    AuthResponse? userSession = await BlocProvider.of<OrderUpdateBloc>(context)
        .authUseCases
        .getUserSession
        .run();
    return userSession?.user.roles?.isNotEmpty == true
        ? userSession?.user.roles!.first.name
        : null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _customerNameController.dispose();
    _commentsController.dispose();
    _tempTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // Si didPop es true, significa que el sistema está intentando hacer pop de la página.
        if (didPop) {
          // No se necesita hacer nada aquí si didPop es true, porque el pop ya está en proceso.
          return;
        }

        // Mostrar el diálogo de confirmación solo si didPop es false, es decir, cuando el pop no se ha iniciado aún.
        final bool? shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmación', style: TextStyle(fontSize: 24)),
            content: Text(
                '¿Estás seguro de que deseas salir? Si hay cambios no guardados se perderán.',
                style: TextStyle(fontSize: 20)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar', style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Salir', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
        // Si el usuario confirma que quiere salir, permitir el pop.
        if (shouldPop == true) {
          BlocProvider.of<OrderUpdateBloc>(context)
              .add(ResetOrderUpdateState());
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<OrderUpdateBloc, OrderUpdateState>(
        listener: (context, state) {
          if (state.response is Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Orden actualizada con éxito',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 800),
              ),
            );
            BlocProvider.of<OrderUpdateBloc>(context)
              ..add(ResetResponseEvent())
              ..add(ResetOrderUpdateState());

            StreamSubscription<OrderUpdateState>? subscription;
            subscription = BlocProvider.of<OrderUpdateBloc>(context)
                .stream
                .listen((updatedState) {
              if (updatedState.response is Initial) {
                subscription?.cancel();
                _navigateToHomePage(context);
              }
            });
          } else if (state.response is Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (state.response as Error).message,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            // Recargar los datos de la orden actual
            BlocProvider.of<OrderUpdateBloc>(context)
                .add(OrderSelectedForUpdate(state.selectedOrder!));
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
              builder: (context, state) {
                return _buildAppBar(context, state);
              },
            ),
          ),
          body: BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
            builder: (context, state) {
              if (state.response is Loading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return _buildBody(context);
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateToHomePage(BuildContext context) {
    if (_userRole == 'Administrador') {
      Navigator.popUntil(context, ModalRoute.withName('salesHome'));
    } else if (_userRole == 'Mesero') {
      Navigator.popUntil(context, ModalRoute.withName('waiterHome'));
    }
  }

  Widget _buildAppBar(BuildContext context, OrderUpdateState state) {
    return AppBar(
      title: Text('Resumen Orden #${state.orderIdSelectedForUpdate ?? ''}'),
      actions: [
        if (_userRole == 'Administrador')
          IconButton(
            icon: Icon(Icons.print, size: 30),
            onPressed: () => _selectAndPrintTicket(context, state),
          ),
        SizedBox(width: 30),
        IconButton(
          icon: Icon(Icons.save, size: 30),
          onPressed: () => _updateOrder(context, state),
        ),
        if (_userRole == 'Administrador')
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'cancel_order') {
                _cancelOrder(context, state);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'cancel_order',
                child: Text('Cancelar Orden'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
      builder: (context, state) {
        if (_phoneController.text != state.phoneNumber) {
          _phoneController.text = state.phoneNumber ?? "";
        }
        if (_addressController.text != state.deliveryAddress) {
          _addressController.text = state.deliveryAddress ?? "";
        }
        if (_customerNameController.text != state.customerName) {
          _customerNameController.text = state.customerName ?? "";
        }
        if (_commentsController.text != state.comments) {
          _commentsController.text = state.comments ?? "";
        }
        if (_tempTableController.text != state.temporaryIdentifier) {
          _tempTableController.text = state.temporaryIdentifier ?? "";
        }

        List<Widget> headerDetails = [];
        headerDetails.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tipo de Pedido',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.green, width: 2.0),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OrderType>(
                value: state.selectedOrderType,
                isExpanded: true,
                onChanged: (OrderType? newValue) {
                  if (newValue != null) {
                    BlocProvider.of<OrderUpdateBloc>(context)
                        .add(OrderTypeSelected(selectedOrderType: newValue));
                  }
                },
                items: OrderType.values.map((OrderType type) {
                  return DropdownMenuItem<OrderType>(
                    value: type,
                    child:
                        Text(_orderTypeTranslations[type] ?? type.toString()),
                  );
                }).toList(),
              ),
            ),
          ),
        ));

        switch (state.selectedOrderType) {
          case OrderType.dineIn:
            if (state.selectedOrderType == OrderType.dineIn &&
                state.areas != null) {
              headerDetails.add(_buildAreaDropdown(context, state));
            }

// Añadir Switch para Crear Mesa Temporal
            headerDetails.add(SwitchListTile(
              title: Text("Crear Mesa Temporal"),
              value: state.isTemporaryTableEnabled,
              onChanged: (bool value) {
                BlocProvider.of<OrderUpdateBloc>(context)
                    .add(ToggleTemporaryTable(value));
              },
            ));

            // Añadir campo para Mesa Temporal si el switch está habilitado
            if (state.isTemporaryTableEnabled) {
              headerDetails.add(Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: TextField(
                  controller: _tempTableController,
                  decoration: InputDecoration(
                    labelText: 'Mesa Temporal',
                    hintText: 'Ingresa el nombre de la mesa temporal',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.green, width: 2.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Envía el evento al bloc con el nuevo valor
                    BlocProvider.of<OrderUpdateBloc>(context)
                        .add(UpdateTemporaryIdentifier(value));
                  },
                ),
              ));
            } else if (state.selectedOrderType == OrderType.dineIn &&
                state.selectedAreaId != null &&
                state.tables != null) {
              headerDetails.add(_buildTableDropdown(context, state));
            }
            break;
          case OrderType.delivery:
            // Usar el _phoneController para el campo de teléfono
            headerDetails.add(Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical:
                      10.0), // Reducir el margen vertical para hacerlo menos ancho
              child: TextField(
                controller:
                    _phoneController, // Usar el controlador inicializado
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ingresa el número de teléfono',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic_none),
                    onPressed: () => _listenForField(_phoneController, (value) {
                      BlocProvider.of<OrderUpdateBloc>(context).add(
                        PhoneNumberEntered(phoneNumber: value),
                      );
                    }, removeSpaces: true),
                  ),
                ),
                onChanged: (value) {
                  BlocProvider.of<OrderUpdateBloc>(context).add(
                    PhoneNumberEntered(phoneNumber: value),
                  );
                },
              ),
            ));
            headerDetails.add(Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Ingresa la dirección de entrega',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic_none),
                    onPressed: () =>
                        _listenForField(_addressController, (value) {
                      BlocProvider.of<OrderUpdateBloc>(context).add(
                        DeliveryAddressEntered(deliveryAddress: value),
                      );
                    }),
                  ),
                ),
                onChanged: (value) {
                  BlocProvider.of<OrderUpdateBloc>(context)
                      .add(DeliveryAddressEntered(deliveryAddress: value));
                },
              ),
            ));
            break;
          case OrderType.pickup:
            headerDetails.add(Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: TextField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Cliente',
                  hintText: 'Ingresa el nombre del cliente',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic_none),
                    onPressed: () =>
                        _listenForField(_customerNameController, (value) {
                      BlocProvider.of<OrderUpdateBloc>(context).add(
                        CustomerNameEntered(customerName: value),
                      );
                    }),
                  ),
                ),
                onChanged: (value) {
                  BlocProvider.of<OrderUpdateBloc>(context).add(
                    CustomerNameEntered(customerName: value),
                  );
                },
              ),
            ));
            headerDetails.add(Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical:
                      10.0), // Reducir el margen vertical para hacerlo menos ancho
              child: TextField(
                controller:
                    _phoneController, // Usar el controlador inicializado
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  hintText: 'Ingresa el número de teléfono',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic_none),
                    onPressed: () => _listenForField(_phoneController, (value) {
                      BlocProvider.of<OrderUpdateBloc>(context).add(
                        PhoneNumberEntered(phoneNumber: value),
                      );
                    }),
                  ),
                ),
                onChanged: (value) {
                  BlocProvider.of<OrderUpdateBloc>(context).add(
                    PhoneNumberEntered(phoneNumber: value),
                  );
                },
              ),
            ));
            break;
          default:
            break;
        }
        // Añadir campo de comentarios debajo de todos los detalles de la cabecera
        headerDetails.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: TextField(
            controller: _commentsController,
            decoration: InputDecoration(
              labelText: 'Comentarios',
              hintText: 'Ingresa comentarios sobre la orden',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.green, width: 2.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic_none),
                onPressed: () => _listenForField(_commentsController, (value) {
                  BlocProvider.of<OrderUpdateBloc>(context).add(
                    OrderCommentsEntered(comments: value),
                  );
                }),
              ),
            ),
            onChanged: (value) {
              BlocProvider.of<OrderUpdateBloc>(context)
                  .add(OrderCommentsEntered(comments: value));
            },
          ),
        ));
        headerDetails.add(BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2, // Ajusta la proporción si es necesario
                  child: Switch(
                    value: state.isTimePickerEnabled ?? false,
                    onChanged: (bool value) {
                      // Envía el evento para habilitar/deshabilitar el TimePicker
                      BlocProvider.of<OrderUpdateBloc>(context)
                          .add(TimePickerEnabled(isTimePickerEnabled: value));
                    },
                  ),
                ),
                Expanded(
                  flex: 8, // Ajusta la proporción si es necesario
                  child: ListTile(
                    title: Text('Seleccionar hora programada'),
                    subtitle: Text(
                      (state.isTimePickerEnabled ?? false) &&
                              state.scheduledDeliveryTime != null
                          ? state.scheduledDeliveryTime!.format(context)
                          : 'No seleccionada',
                    ),
                    leading: Icon(Icons.access_time, size: 30),
                    onTap: state.isTimePickerEnabled ?? false
                        ? () => _selectTime(context)
                        : null, // Asegúrate de que onTap permita la selección de la hora solo si isTimePickerEnabled es true
                  ),
                ),
              ],
            );
          },
        ));

        int headerCount =
            headerDetails.length; // Número de elementos en el encabezado
        int orderItemsCount =
            state.orderItems?.length ?? 0; // Número de OrderItems
        int orderAdjustmentsCount = state.orderAdjustments?.length ?? 0;

        return Scaffold(
          body: ListView.builder(
            itemCount: headerCount +
                orderItemsCount +
                orderAdjustmentsCount +
                (state.selectedOrder?.amountPaid != null &&
                        state.selectedOrder!.amountPaid! > 0
                    ? 5
                    : 3),
            itemBuilder: (context, index) {
              if (index < headerCount) {
                // Devuelve el widget de encabezado correspondiente
                return headerDetails[index];
              } else if (index < headerCount + orderItemsCount) {
                // Devuelve el widget de OrderItem correspondiente
                final orderItemIndex = index - headerCount;
                final orderItem = state.orderItems![orderItemIndex];

                List<Widget> details = [];

                Color textColor = Colors.white;
                switch (orderItem.status) {
                  case OrderItemStatus.created:
                    textColor = Colors.white;
                    break;
                  case OrderItemStatus.in_preparation:
                    textColor = Colors.blue;
                    break;
                  case OrderItemStatus.prepared:
                    textColor = Colors.orange;
                    break;
                  default:
                    textColor = Colors.white;
                }

                if (orderItem.productVariant != null) {
                  details.add(Text(
                    'Variante: ${orderItem.productVariant?.shortName}',
                    style: TextStyle(color: textColor),
                  ));
                }
                if (orderItem.selectedModifiers != null &&
                    orderItem.selectedModifiers!.isNotEmpty) {
                  details.add(Text(
                    'Modificadores: ${orderItem.selectedModifiers!.map((m) => m.modifier?.shortName).join(', ')}',
                    style: TextStyle(color: textColor),
                  ));
                }
                if (orderItem.selectedPizzaFlavors != null &&
                    orderItem.selectedPizzaFlavors!.isNotEmpty) {
                  details.add(Text(
                    'Sabor: ${orderItem.selectedPizzaFlavors!.map((f) => f.pizzaFlavor?.name).join('/')}',
                    style: TextStyle(color: textColor),
                  ));
                }
                if (orderItem.selectedPizzaIngredients != null &&
                    orderItem.selectedPizzaIngredients!.isNotEmpty) {
                  final ingredientsLeft = orderItem.selectedPizzaIngredients!
                      .where((i) => i.half == PizzaHalf.left)
                      .map((i) => i.action == IngredientAction.remove
                          ? 'Sin ${i.pizzaIngredient?.name}'
                          : i.pizzaIngredient?.name)
                      .join(', ');
                  final ingredientsRight = orderItem.selectedPizzaIngredients!
                      .where((i) => i.half == PizzaHalf.right)
                      .map((i) => i.action == IngredientAction.remove
                          ? 'Sin ${i.pizzaIngredient?.name}'
                          : i.pizzaIngredient?.name)
                      .join(', ');
                  final ingredientsNone = orderItem.selectedPizzaIngredients!
                      .where((i) => i.half == PizzaHalf.full)
                      .map((i) => i.action == IngredientAction.remove
                          ? 'Sin ${i.pizzaIngredient?.name}'
                          : i.pizzaIngredient?.name)
                      .join(', ');

                  String ingredientsText = '';
                  if (ingredientsLeft.isNotEmpty ||
                      ingredientsRight.isNotEmpty) {
                    ingredientsText =
                        '$ingredientsLeft / $ingredientsRight'.trim();
                  }
                  if (ingredientsNone.isNotEmpty) {
                    if (ingredientsText.isNotEmpty) ingredientsText += ' | ';
                    ingredientsText += '$ingredientsNone';
                  }

                  details.add(Text(
                    'Ingredientes: $ingredientsText',
                    style: TextStyle(color: textColor),
                  ));
                }
                if (orderItem.comments != null &&
                    orderItem.comments!.isNotEmpty) {
                  details.add(Text(
                    'Comentarios: ${orderItem.comments}',
                    style: TextStyle(color: textColor),
                  ));
                }

                return Dismissible(
                  key: Key(orderItem.tempId
                      .toString()), // Asegúrate de que la clave sea única para cada elemento
                  direction: orderItem.status == OrderItemStatus.prepared
                      ? DismissDirection.none
                      : DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (orderItem.status == OrderItemStatus.in_preparation) {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirmación"),
                            content: Text(
                                "Este producto está en preparación. ¿Deseas eliminarlo?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("No"),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: Text("Sí"),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return orderItem.status != OrderItemStatus.prepared;
                  },
                  onDismissed: (direction) {
                    // Aquí manejas la eliminación del elemento
                    BlocProvider.of<OrderUpdateBloc>(context)
                        .add(RemoveOrderItem(tempId: orderItem.tempId!));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: InkWell(
                    onTap: () {
                      final orderItemStatus = orderItem.status;
                      switch (orderItemStatus) {
                        case OrderItemStatus.created:
                          // Buscar el producto por ID en las categorías cargadas en el estado
                          Product? foundProduct;
                          for (var category in state.categories!) {
                            for (var subcategory
                                in category.subcategories ?? []) {
                              for (var product in subcategory.products ?? []) {
                                if (product.id == orderItem.product!.id) {
                                  foundProduct = product;
                                  break;
                                }
                              }
                              if (foundProduct != null) break;
                            }
                            if (foundProduct != null) break;
                          }

                          // Asumiendo que siempre se encuentra el producto, redirige a la página de personalización
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateProductPersonalizationPage(
                                product:
                                    foundProduct!, // Aquí se asume que el producto siempre se encuentra
                                existingOrderItem: orderItem,
                                bloc: BlocProvider.of<OrderUpdateBloc>(context),
                                state: BlocProvider.of<OrderUpdateBloc>(context)
                                    .state,
                              ),
                            ),
                          );
                          break;
                        case OrderItemStatus.in_preparation:
                          // Muestra un diálogo para confirmar si desea actualizar un producto en preparación
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirmación"),
                                content: Text(
                                    "Este producto está en preparación. ¿Deseas actualizarlo?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("Cancelar"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Actualizar"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Buscar el producto por ID
                                      Product? foundProduct;
                                      for (var category in state.categories!) {
                                        for (var subcategory
                                            in category.subcategories ?? []) {
                                          for (var product
                                              in subcategory.products ?? []) {
                                            if (product.id ==
                                                orderItem.product!.id) {
                                              foundProduct = product;
                                              break;
                                            }
                                          }
                                          if (foundProduct != null) break;
                                        }
                                        if (foundProduct != null) break;
                                      }

                                      // Asumiendo que siempre se encuentra el producto, redirige a la página de personalización
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateProductPersonalizationPage(
                                            product:
                                                foundProduct!, // Aquí se asume que el producto siempre se encuentra
                                            existingOrderItem: orderItem,
                                            bloc: BlocProvider.of<
                                                OrderUpdateBloc>(context),
                                            state: BlocProvider.of<
                                                    OrderUpdateBloc>(context)
                                                .state,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                        case OrderItemStatus.prepared:
                          // No permite la redirección y muestra un mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Este producto ya está preparado y no puede ser modificado."),
                              duration: Duration(milliseconds: 700),
                            ),
                          );
                          break;
                        default:
                          // Manejo de otros estados si es necesario
                          break;
                      }
                    },
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              orderItem.product?.shortName ?? '',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          Text(
                              '\$${orderItem.price?.toStringAsFixed(2) ?? ''}'),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: details,
                      ),
                    ),
                  ),
                );
              } else if (index <
                  headerCount + orderItemsCount + orderAdjustmentsCount) {
                final adjustmentIndex = index - (headerCount + orderItemsCount);
                final adjustment = state.orderAdjustments![adjustmentIndex];
                return ListTile(
                  title: Text(adjustment.name ?? ''),
                  trailing: Text(
                      adjustment.amount! < 0
                          ? '-\$${(-adjustment.amount!).toStringAsFixed(2)}'
                          : '\$${adjustment.amount?.toStringAsFixed(2) ?? ''}',
                      style: TextStyle(
                        fontSize:
                            16.0, // Ajuste para igualar la fuente de los orderItems
                      )),
                  onTap: () {
                    _showAddOrderAdjustmentDialog(context,
                        existingAdjustment: adjustment);
                  },
                );
              } else if (index ==
                  headerCount + orderItemsCount + orderAdjustmentsCount) {
                // Widget para mostrar el total
                return ListTile(
                  title: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 25.0, // Tamaño de letra más grande
                      fontStyle: FontStyle.italic, // Letra en cursiva
                    ),
                  ),
                  trailing: Text(
                    '\$${calculateTotal(state.orderItems, state.orderAdjustments).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 25.0, // Tamaño de letra más grande
                      fontStyle: FontStyle.italic, // Letra en cursiva
                    ),
                  ),
                );
              } else if (state.selectedOrder?.amountPaid != null &&
                  state.selectedOrder!.amountPaid! > 0 &&
                  index ==
                      headerCount +
                          orderItemsCount +
                          orderAdjustmentsCount +
                          1) {
                // Widget para mostrar el total pagado
                return ListTile(
                  title: Text(
                    'Total Pagado',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '\$${state.selectedOrder!.amountPaid!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (state.selectedOrder?.amountPaid != null &&
                  state.selectedOrder!.amountPaid! > 0 &&
                  index ==
                      headerCount +
                          orderItemsCount +
                          orderAdjustmentsCount +
                          2) {
                // Widget para mostrar el restante
                final remaining =
                    calculateTotal(state.orderItems, state.orderAdjustments) -
                        state.selectedOrder!.amountPaid!;
                return ListTile(
                  title: Text(
                    'Restante',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '\$${remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (index ==
                  headerCount +
                      orderItemsCount +
                      orderAdjustmentsCount +
                      (state.selectedOrder?.amountPaid != null &&
                              state.selectedOrder!.amountPaid! > 0
                          ? 3
                          : 1)) {
                // Botón para agregar un ajuste de orden
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () => _showAddOrderAdjustmentDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      textStyle: TextStyle(fontSize: 20),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Agregar ajuste de orden'),
                  ),
                );
              } else if (index ==
                  headerCount +
                      orderItemsCount +
                      orderAdjustmentsCount +
                      (state.selectedOrder?.amountPaid != null &&
                              state.selectedOrder!.amountPaid! > 0
                          ? 4
                          : 2)) {
                return _buildAddProductButton(context);
              }
              throw Exception('Índice inesperado: $index');
            },
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Registrar Pago
              if (_userRole == 'Administrador')
                FloatingActionButton(
                  onPressed: () {
                    _showPaymentDialog(
                        context, state.selectedOrder!.totalCost ?? 0.0, state);
                  },
                  child: Icon(Icons.payment),
                  tooltip: 'Registrar Pago',
                  backgroundColor: Colors.blue,
                ),

              if (_userRole == 'Administrador' &&
                  state.selectedOrder?.status == OrderStatus.prepared &&
                  state.selectedOrder?.amountPaid != null &&
                  state.selectedOrder!.amountPaid! -
                          calculateTotal(
                              state.orderItems, state.orderAdjustments) ==
                      0)
                SizedBox(height: 10),

              // Botón Terminar Orden
              if (_userRole == 'Administrador' &&
                  state.selectedOrder?.status == OrderStatus.prepared &&
                  state.selectedOrder?.amountPaid != null &&
                  state.selectedOrder!.amountPaid! >=
                      calculateTotal(state.orderItems, state.orderAdjustments))
                FloatingActionButton(
                  onPressed: () {
                    if (state.selectedOrder?.id != null) {
                      BlocProvider.of<OrderUpdateBloc>(context)
                          .add(FinishOrder(orderId: state.selectedOrder!.id!));
                      // Navegar de vuelta a la página anterior después de terminar la orden
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  child: Icon(Icons.check),
                  backgroundColor: Colors.green,
                  tooltip: 'Terminar Orden',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.add, size: 30.0), // Icono más grande
        label: Text('Agregar Productos',
            style: TextStyle(fontSize: 18.0)), // Texto más grande
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
      ),
    );
  }

  void _updateOrder(BuildContext context, OrderUpdateState state) async {
    if (state.orderItems == null || state.orderItems!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'No se puede enviar la orden sin productos.',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Salir del método para evitar enviar la orden
    }

    // Verificaciones adicionales basadas en el tipo de orden
    switch (state.selectedOrderType) {
      case OrderType.dineIn:
        if (state.selectedAreaId == null ||
            (!state.isTemporaryTableEnabled &&
                (state.selectedTableId == null ||
                    state.selectedTableId == 0)) ||
            (state.isTemporaryTableEnabled &&
                (_tempTableController.text.isEmpty))) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                'Selecciona un área y una mesa para continuar.',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return; // Salir del método para evitar enviar la orden
        }
        break;
      case OrderType.delivery:
        if (state.deliveryAddress == null || state.deliveryAddress!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                'La dirección de entrega es necesaria para continuar.',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return; // Salir del método para evitar enviar la orden
        }
        break;
      case OrderType.pickup:
        if (state.customerName == null || state.customerName!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                'El nombre del cliente es necesario para continuar.',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return; // Salir del método para evitar enviar la orden
        }
        break;
      default:
        break; // No se requieren verificaciones adicionales para otros tipos de orden
    }
    BlocProvider.of<OrderUpdateBloc>(context).add(UpdateOrder());
  }

  Widget _buildAreaDropdown(BuildContext context, OrderUpdateState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Área',
          contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<int>(
            value: state.selectedAreaId,
            isExpanded: true,
            onChanged: (int? newValue) {
              if (newValue != null) {
                BlocProvider.of<OrderUpdateBloc>(context)
                    .add(AreaSelected(areaId: newValue));
              }
            },
            items: state.areas!.map<DropdownMenuItem<int>>((area) {
              return DropdownMenuItem<int>(
                value: area.id,
                child: Text(area.name!),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTableDropdown(BuildContext context, OrderUpdateState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Mesa',
          contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<int>(
            value: state.tables?.any((table) =>
                        table.id == state.selectedTableId &&
                        table.number != null) ??
                    false
                ? state.selectedTableId
                : null,
            isExpanded: true,
            onChanged: (int? newValue) {
              if (newValue != null) {
                BlocProvider.of<OrderUpdateBloc>(context)
                    .add(TableSelected(tableId: newValue));
              }
            },
            items: state.tables
                    ?.where((table) =>
                        table.number != null &&
                            table.status?.name == 'Disponible' ||
                        table.id == state.selectedTableId)
                    .map<DropdownMenuItem<int>>((table) {
                  return DropdownMenuItem<int>(
                    value: table.id,
                    child: Text(table.number.toString()),
                  );
                }).toList() ??
                [],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Envía el evento TimeSelected con el tiempo elegido
      BlocProvider.of<OrderUpdateBloc>(context).add(TimeSelected(time: picked));
    }
  }

  double calculateTotal(
      List<OrderItem>? orderItems, List<OrderAdjustment>? orderAdjustments) {
    double itemsTotal = orderItems?.fold<double>(0.0,
            (double total, OrderItem item) => total + (item.price ?? 0.0)) ??
        0.0;
    double adjustmentsTotal = orderAdjustments?.fold<double>(
            0.0,
            (double total, OrderAdjustment adjustment) =>
                total + (adjustment.amount ?? 0.0)) ??
        0.0;
    return itemsTotal + adjustmentsTotal;
  }

  void _cancelOrder(BuildContext context, OrderUpdateState state) async {
    if (state.orderIdSelectedForUpdate != null) {
      final bool? shouldCancel = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmación', style: TextStyle(fontSize: 24)),
          content: Text(
            '¿Estás seguro de que deseas cancelar esta orden?',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Sí', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );

      if (shouldCancel == true) {
        BlocProvider.of<OrderUpdateBloc>(context).add(CancelOrder());
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showAddOrderAdjustmentDialog(BuildContext context,
      {OrderAdjustment? existingAdjustment}) async {
    String? name = existingAdjustment?.name;
    String? amountString = existingAdjustment?.amount?.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingAdjustment == null
              ? 'Agregar ajuste de orden'
              : 'Editar ajuste de orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  name = value;
                },
                controller: TextEditingController(text: name),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amountString = value;
                },
                controller: TextEditingController(text: amountString),
              ),
            ],
          ),
          actions: [
            if (existingAdjustment != null)
              TextButton(
                onPressed: () {
                  BlocProvider.of<OrderUpdateBloc>(context).add(
                    OrderAdjustmentRemoved(orderAdjustment: existingAdjustment),
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (name != null && amountString != null) {
                  double? amount = double.tryParse(amountString!);
                  if (amount != null) {
                    BlocProvider.of<OrderUpdateBloc>(context).add(
                      existingAdjustment == null
                          ? OrderAdjustmentAdded(
                              orderAdjustment: OrderAdjustment(
                                name: name,
                                amount: amount,
                              ),
                            )
                          : OrderAdjustmentUpdated(
                              orderAdjustment: existingAdjustment.copyWith(
                                name: name,
                                amount: amount,
                              ),
                            ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              child:
                  Text(existingAdjustment == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(
      BuildContext context, double totalCost, OrderUpdateState state) {
    final TextEditingController _paymentController = TextEditingController();
    double _amountPaid = 0.0;
    double alreadyPaid = state.selectedOrder?.amountPaid ?? 0.0;
    double remainingAmount = totalCost - alreadyPaid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Registrar Pago'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Total: \$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  if (alreadyPaid > 0)
                    Text(
                      'Pagado: \$${alreadyPaid.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  if (alreadyPaid > 0)
                    Text(
                      'Restante: \$${remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  TextField(
                    controller: _paymentController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Cantidad Pagada',
                    ),
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value) ?? 0.0;
                      setState(() {
                        _amountPaid = parsedValue;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  if (_amountPaid >= remainingAmount)
                    Text(
                      'Cambio: \$${(_amountPaid - remainingAmount).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    _paymentController.clear();
                    setState(() {
                      _amountPaid = 0.0;
                    });
                    if (state.selectedOrder?.id != null) {
                      BlocProvider.of<OrderUpdateBloc>(context).add(
                        RegisterPayment(
                          orderId: state.selectedOrder!.id!,
                          amount: 0.0,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Borrar Pago'),
                ),
                TextButton(
                  onPressed: _amountPaid >= remainingAmount
                      ? () {
                          if (state.selectedOrder?.id != null) {
                            BlocProvider.of<OrderUpdateBloc>(context).add(
                              RegisterPayment(
                                orderId: state.selectedOrder!.id!,
                                amount: totalCost,
                              ),
                            );
                            Navigator.pop(
                                context); // Cierra la página actual antes de navegar
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderUpdatePage(),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text('Registrar Pago'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled))
                          return Colors.grey;
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _removeAccents(String input) {
    const accents = 'áéíóúÁÉÍÓÚñÑ';
    const withoutAccents = 'aeiouAEIOUnN';
    String output = input;
    for (int i = 0; i < accents.length; i++) {
      output = output.replaceAll(accents[i], withoutAccents[i]);
    }
    return output;
  }

  Future<void> _selectAndPrintTicket(
      BuildContext context, OrderUpdateState state) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
    const int maxRetries = 1;
    const Duration timeoutDuration = Duration(seconds: 3);

    // Verificar si ya está conectado y desconectar si es necesario
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != null && isConnected) {
      await bluetooth.disconnect();
      await Future.delayed(Duration(
          seconds: 1)); // Esperar un momento para asegurar la desconexión
    }

    // Obtener dispositivos emparejados
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontraron impresoras Bluetooth.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Muestra un diálogo para seleccionar la impresora y el tamaño del papel
    Map<String, dynamic>? selection = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String selectedPaperSize = '58mm';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Seleccionar impresora y papel'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListBody(
                      children: devices
                          .map((device) => RadioListTile<BluetoothDevice>(
                                title: Text(device.name ?? ''),
                                value: device,
                                groupValue: null,
                                onChanged: (BluetoothDevice? value) {
                                  Navigator.pop(context, {
                                    'device': value,
                                    'paperSize': selectedPaperSize
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Tamaño del papel'),
                      trailing: DropdownButton<String>(
                        value: selectedPaperSize,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaperSize = newValue!;
                          });
                        },
                        items: <String>['58mm', '80mm']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selection != null) {
      BluetoothDevice? selectedDevice = selection['device'];
      String selectedPaperSize = selection['paperSize'];

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          // Verificar si ya está conectado y desconectar si es necesario
          isConnected = await bluetooth.isConnected;
          if (isConnected != null && isConnected) {
            await bluetooth.disconnect();
            await Future.delayed(Duration(
                seconds: 2)); // Esperar un momento para asegurar la desconexión
          }

          // Conectar con la impresora seleccionada
          if (selectedDevice != null) {
            await bluetooth.connect(selectedDevice).timeout(timeoutDuration);
          }

          // Generar el contenido del ticket según el tamaño del papel seleccionado
          List<int> ticketContent = await _generateTicketContent58(state);
          if (selectedPaperSize == '80mm') {
            ticketContent = await _generateTicketContent80(state);
          }

          // Imprimir el ticket
          await bluetooth.writeBytes(Uint8List.fromList(ticketContent));

          // Desconectar de la impresora
          await bluetooth.disconnect();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ticket impreso correctamente.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          if (state.orderIdSelectedForUpdate != null) {
            BlocProvider.of<OrderUpdateBloc>(context).add(
              RegisterTicketPrint(orderId: state.orderIdSelectedForUpdate!),
            );
          }
          return; // Salir de la función si la impresión fue exitosa
        } catch (e) {
          if (attempt == maxRetries) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al imprimir el ticket: $e'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }
  }

  Future<List<int>> _generateTicketContent58(OrderUpdateState state) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(
      _removeAccents('Orden #${state.orderIdSelectedForUpdate ?? ''}'),
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size2,
        bold: true,
        fontType: PosFontType.fontA,
      ),
    );

    bytes += generator.feed(1);

    switch (state.selectedOrderType) {
      case OrderType.delivery:
        bytes += generator.text(
          _removeAccents('Telefono: ${state.phoneNumber}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents('Direccion: ${state.deliveryAddress ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      case OrderType.dineIn:
        bytes += generator.text(
          _removeAccents(
              'Area: ${state.areas?.firstWhere((area) => area.id == state.selectedAreaId).name ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents(
              'Mesa: ${state.tables != null ? state.tables!.firstWhere((table) => table.id == state.selectedTableId, orElse: () => RestauranteTable.Table()).number : ''} ${state.temporaryIdentifier ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      case OrderType.pickup:
        bytes += generator.text(
          _removeAccents('Nombre del Cliente: ${state.customerName}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents('Telefono: ${state.phoneNumber}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      default:
        break;
    }

    String formattedCreationDate =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    bytes += generator.text(
      'Fecha: $formattedCreationDate',
      styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1),
    );

    bytes += generator.hr();

    // Imprimir los detalles de los productos de la orden
    state.orderItems?.forEach((item) {
      String productName = _removeAccents(
          item.productVariant?.shortName ?? item.product?.shortName ?? '');
      String productPrice = '\$${item.price?.toStringAsFixed(2) ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: productName,
          width: 9,
          styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1),
        ),
        PosColumn(
          text: productPrice,
          width: 3,
          styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1),
        ),
      ]);

      // Agregar detalles adicionales como modificadores, ingredientes, etc.
      // ... (código similar al método _generateTicketContent original)
    });

    // Procesamiento de los ajustes de la orden
    state.orderAdjustments?.forEach((adjustment) {
      String adjustmentName = _removeAccents(adjustment.name ?? '');
      String adjustmentAmount = adjustment.amount! < 0
          ? '-\$${(-adjustment.amount!).toStringAsFixed(2)}'
          : '\$${adjustment.amount?.toStringAsFixed(2) ?? ''}';

      bytes += generator.row([
        PosColumn(
            text: adjustmentName,
            width: 9,
            styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: adjustmentAmount,
            width: 3,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    });

    bytes += generator.hr();
    bytes += generator.text(
      'Total: \$${calculateTotal(state.orderItems, state.orderAdjustments).toStringAsFixed(2)}',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size3,
          width: PosTextSize.size2),
    );

    // Verificar si hay un pago registrado
    if (state.selectedOrder != null) {
      double amountPaid = state.selectedOrder!.amountPaid ?? 0;
      double total = calculateTotal(state.orderItems, state.orderAdjustments);
      double remaining = total - amountPaid;

      if (amountPaid > 0) {
        bytes += generator.text('Pagado: \$${amountPaid.toStringAsFixed(2)}');
        bytes += generator.text('Resto: \$${remaining.toStringAsFixed(2)}');
      }
    }

    bytes += generator.text(
      _removeAccents('\n" Gracias por su preferencia "\n'),
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2);

    return bytes;
  }

  Future<List<int>> _generateTicketContent80(OrderUpdateState state) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(
      _removeAccents('Orden #${state.orderIdSelectedForUpdate ?? ''}'),
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size2,
        bold: true,
        fontType: PosFontType.fontA,
      ),
    );

    bytes += generator.feed(1);

    switch (state.selectedOrderType) {
      case OrderType.delivery:
        bytes += generator.text(
          _removeAccents('Telefono: ${state.phoneNumber}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents('Direccion: ${state.deliveryAddress ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      case OrderType.dineIn:
        bytes += generator.text(
          _removeAccents(
              'Area: ${state.areas?.firstWhere((area) => area.id == state.selectedAreaId).name ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents(
              'Mesa: ${state.tables != null ? state.tables!.firstWhere((table) => table.id == state.selectedTableId, orElse: () => RestauranteTable.Table()).number : ''} ${state.temporaryIdentifier ?? ''}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      case OrderType.pickup:
        bytes += generator.text(
          _removeAccents('Nombre del Cliente: ${state.customerName}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        bytes += generator.text(
          _removeAccents('Telefono: ${state.phoneNumber}'),
          styles: PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size1, bold: true),
        );
        break;
      default:
        break;
    }

    String formattedCreationDate =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    bytes += generator.text(
      'Fecha: $formattedCreationDate',
      styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1),
    );

    bytes += generator.hr();

    // Imprimir los detalles de los productos de la orden
    state.orderItems?.forEach((item) {
      String productName = _removeAccents(
          item.productVariant?.shortName ?? item.product?.shortName ?? '');
      String productPrice = '\$${item.price?.toStringAsFixed(2) ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: productName,
          width: 9,
          styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size1),
        ),
        PosColumn(
          text: productPrice,
          width: 3,
          styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1),
        ),
      ]);

      // Agregar detalles adicionales como modificadores, ingredientes, etc.
      // ... (código similar al método _generateTicketContent original)
    });

    // Procesamiento de los ajustes de la orden
    state.orderAdjustments?.forEach((adjustment) {
      String adjustmentName = _removeAccents(adjustment.name ?? '');
      String adjustmentAmount = adjustment.amount! < 0
          ? '-\$${(-adjustment.amount!).toStringAsFixed(2)}'
          : '\$${adjustment.amount?.toStringAsFixed(2) ?? ''}';

      bytes += generator.row([
        PosColumn(
            text: adjustmentName,
            width: 9,
            styles: PosStyles(align: PosAlign.left)),
        PosColumn(
            text: adjustmentAmount,
            width: 3,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    });

    bytes += generator.hr();
    bytes += generator.text(
      'Total: \$${calculateTotal(state.orderItems, state.orderAdjustments).toStringAsFixed(2)}',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size3,
          width: PosTextSize.size2),
    );

    // Verificar si hay un pago registrado
    if (state.selectedOrder != null) {
      double amountPaid = state.selectedOrder!.amountPaid ?? 0;
      double total = calculateTotal(state.orderItems, state.orderAdjustments);
      double remaining = total - amountPaid;

      if (amountPaid > 0) {
        bytes += generator.text('Pagado: \$${amountPaid.toStringAsFixed(2)}');
        bytes += generator.text('Resto: \$${remaining.toStringAsFixed(2)}');
      }
    }

    bytes += generator.text(
      _removeAccents('\n" Gracias por su preferencia "\n'),
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    bytes += generator.cut();

    return bytes;
  }

  void _listenForField(
      TextEditingController controller, Function(String) onResultCallback,
      {bool removeSpaces = false}) async {
    if (!(_speech.isListening)) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (val) {
            String processedText = val.recognizedWords;
            // Verificar si se deben eliminar los espacios
            if (removeSpaces) {
              processedText = processedText.replaceAll(' ', '');
            }
            controller.text = processedText;
            onResultCallback(processedText);
          },
          listenOptions: stt.SpeechListenOptions(
            cancelOnError: true,
          ),
        );
      }
    } else {
      _speech.stop();
    }
  }
}
