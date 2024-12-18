import 'package:restaurante/src/domain/models/ModifierType.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/PizzaFlavor.dart';
import 'package:restaurante/src/domain/models/PizzaIngredient.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/ProductVariant.dart';
import 'package:restaurante/src/domain/models/SelectedModifier.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaFlavor.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProductPersonalizationPage extends StatefulWidget {
  final Product product;
  final OrderItem? existingOrderItem;
  final OrderCreationBloc bloc;
  final OrderCreationState state;

  const ProductPersonalizationPage({
    Key? key,
    required this.product,
    this.existingOrderItem,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  _ProductPersonalizationPageState createState() =>
      _ProductPersonalizationPageState();
}

class _ProductPersonalizationPageState
    extends State<ProductPersonalizationPage> {
  ProductVariant? selectedVariant;
  List<SelectedModifier> selectedModifiers = [];
  List<SelectedPizzaIngredient> selectedPizzaIngredients = [];
  List<SelectedPizzaFlavor> selectedPizzaFlavors = [];
  String? comments;
  bool _showPizzaIngredients = false;
  bool _createTwoHalves = false;
  double _currentPrice = 0.0;
  bool _isIngredientsExpanded = false;
  bool _isLeftExpanded = false;
  bool _isRightExpanded = false;
  int productCount = 0; // Added to manage product count state
  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    productCount = widget.state.orderItems
            ?.where((item) => item.product?.id == widget.product.id)
            .length ??
        0;

    if (widget.existingOrderItem != null) {
      selectedVariant = widget.existingOrderItem!.productVariant;
      selectedModifiers =
          List.from(widget.existingOrderItem?.selectedModifiers ?? []);
      selectedPizzaFlavors =
          List.from(widget.existingOrderItem?.selectedPizzaFlavors ?? []);
      selectedPizzaIngredients =
          List.from(widget.existingOrderItem?.selectedPizzaIngredients ?? []);
      comments = widget.existingOrderItem!.comments;

      // Detecta si se deben habilitar los botones de "Armar pizza" y "Crear dos mitades"
      if (selectedPizzaIngredients.isNotEmpty) {
        _showPizzaIngredients =
            true; // Habilita "Armar pizza" si hay ingredientes seleccionados

        // Verifica si hay ingredientes asignados a una mitad específica para habilitar "Crear dos mitades"
        _createTwoHalves = selectedPizzaIngredients
            .any((ingredient) => ingredient.half != PizzaHalf.full);
      }
    }

    _updatePrice();
  }

  void _updatePrice() {
    double price = _calculatePrice();

    setState(() {
      _currentPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verifica si el producto es una pizza
    bool isPizza = widget.product.pizzaFlavors != null &&
        widget.product.pizzaFlavors!.isNotEmpty &&
        widget.product.pizzaIngredients != null &&
        widget.product.pizzaIngredients!.isNotEmpty;

    // Determina si el botón de enviar debe habilitarse
    bool enableSaveButton = true; // Inicialmente habilitado

// Verifica si hay variantes de producto disponibles
    bool hasVariants = widget.product.productVariants != null &&
        widget.product.productVariants!.isNotEmpty;

// Si hay variantes, entonces requiere que una variante esté seleccionada para habilitar el botón
    if (hasVariants) {
      enableSaveButton = selectedVariant != null;
    }
    if (isPizza) {
      if (!_showPizzaIngredients) {
        // Si "Armar pizza" está deshabilitado, requiere al menos un sabor de pizza seleccionado
        enableSaveButton &= selectedPizzaFlavors.isNotEmpty;
      } else {
        // Si "Armar pizza" está habilitado, requiere al menos un ingrediente de pizza seleccionado
        enableSaveButton &= selectedPizzaIngredients.isNotEmpty;
        if (_createTwoHalves) {
          // Si "Crear dos mitades" está habilitado, verifica que haya ingredientes para ambas mitades
          bool hasLeftIngredients = selectedPizzaIngredients
              .any((ingredient) => ingredient.half == PizzaHalf.left);
          bool hasRightIngredients = selectedPizzaIngredients
              .any((ingredient) => ingredient.half == PizzaHalf.right);
          enableSaveButton &= hasLeftIngredients && hasRightIngredients;
        }
      }
    }

    return BlocListener<OrderCreationBloc, OrderCreationState>(
      listener: (context, state) {
        // Recalcula productCount cuando la lista orderItems cambia
        if (state.orderItems != widget.state.orderItems) {
          setState(() {
            productCount = state.orderItems
                    ?.where((item) => item.product?.id == widget.product.id)
                    .length ??
                0;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                widget.product.shortName,
                style:
                    TextStyle(fontSize: 26), // Cambiado a una fuente más grande
              ),
              Spacer(),
              if (widget.existingOrderItem == null && productCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '($productCount)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              Text(
                '\$${_currentPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            if (widget.existingOrderItem ==
                null) // Only show the button if there is no existing OrderItem
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 40),
                onPressed: enableSaveButton ? _saveAndReset : null,
                tooltip: 'Guardar y agregar otro',
              ),
            IconButton(
              icon: Icon(Icons.save, size: 40),
              onPressed: enableSaveButton ? _saveOrderItem : null,
            ),
            SizedBox(width: 20),
            if (widget.existingOrderItem != null)
              IconButton(
                icon: Icon(Icons.delete, size: 40),
                onPressed: _deleteOrderItem,
              ),
          ],
        ),
        body: ListView(
          children: [
            // Muestra el switch solo si el producto es una pizza
            if (isPizza)
              SwitchListTile(
                title: Text('Armar pizza',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                value: _showPizzaIngredients,
                onChanged: (bool value) {
                  setState(() {
                    _showPizzaIngredients = value;
                    if (value) {
                      selectedPizzaFlavors.clear();
                      selectedPizzaIngredients.clear();
                    } else {
                      // Aquí se agrega la lógica para borrar los ingredientes cuando se deselecciona "Armar pizza"
                      selectedPizzaIngredients
                          .clear(); // Borra los ingredientes de pizza seleccionados
                    }
                    _updatePrice();
                  });
                },
              ),
            if (isPizza && _showPizzaIngredients)
              SwitchListTile(
                  title: Text('Crear dos mitades',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _createTwoHalves,
                  onChanged: (bool value) {
                    setState(() {
                      _createTwoHalves = value;
                      // Al activar o desactivar, reinicia los ingredientes seleccionados
                      selectedPizzaIngredients.clear();
                      _updatePrice();
                    });
                  }),
            if (widget.product.productVariants != null)
              _buildVariantSelector(widget.product.productVariants!),
            // Muestra los sabores de pizza solo si el producto es una pizza y _showPizzaIngredients es falso
            if (!_showPizzaIngredients && isPizza)
              _buildPizzaFlavorSelector(widget.product.pizzaFlavors!),
            // Muestra los ingredientes de pizza solo si el producto es una pizza y _showPizzaIngredients es verdadero
            if (_showPizzaIngredients && isPizza)
              _buildPizzaIngredientSelector(widget.product.pizzaIngredients!),
            if (widget.product.modifierTypes != null)
              ...widget.product.modifierTypes!
                  .map(_buildModifierTypeSection)
                  .toList(),
            SizedBox(height: 16.0), // Espaciado agregado arriba de comentarios
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: TextEditingController(text: comments),
                decoration: InputDecoration(
                  labelText: 'Comentarios',
                  labelStyle: TextStyle(fontSize: 22),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: _listen,
                  ),
                ),
                onChanged: (value) {
                  comments = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrderItem({bool resetAfterSave = false}) async {
    double price = _calculatePrice();

    // Genera un nuevo tempId si es un nuevo OrderItem, de lo contrario, usa el existente
    final tempId = widget.existingOrderItem?.tempId ?? Uuid().v4();

    if (widget.existingOrderItem != null) {
      // Actualizar el OrderItem existente
      final updatedOrderItem = widget.existingOrderItem!.copyWith(
        tempId: tempId, // Asegúrate de pasar el tempId existente
        product: widget.product,
        productVariant: selectedVariant,
        selectedModifiers: selectedModifiers,
        selectedPizzaFlavors: selectedPizzaFlavors,
        selectedPizzaIngredients: selectedPizzaIngredients,
        comments: comments,
        price: price,
      );

      // Envía el evento de actualización a tu Bloc
      BlocProvider.of<OrderCreationBloc>(context)
          .add(UpdateOrderItem(orderItem: updatedOrderItem));
    } else {
      // Creación del OrderItem con los datos necesarios, incluyendo el precio calculado
      final orderItem = OrderItem(
        tempId: tempId, // Usa el nuevo tempId generado
        product: widget.product,
        productVariant: selectedVariant,
        selectedModifiers: selectedModifiers,
        selectedPizzaFlavors: selectedPizzaFlavors,
        selectedPizzaIngredients: selectedPizzaIngredients,
        comments: comments,
        status: OrderItemStatus.created,
        price: price,
      );

      // Obtener el OrderCreationBloc y enviar el evento para añadir el OrderItem
      BlocProvider.of<OrderCreationBloc>(context)
          .add(AddOrderItem(orderItem: orderItem));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
            'Producto ${widget.existingOrderItem != null ? 'actualizado' : 'añadido'} con éxito',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        duration: Duration(milliseconds: 200),
      ),
    );

    if (!resetAfterSave) {
      Navigator.pop(context);
    }
  }

  void _saveAndReset() async {
    await _saveOrderItem(resetAfterSave: true);
    _resetFields();
  }

  void _resetFields() {
    setState(() {
      selectedVariant = null;
      selectedModifiers = [];
      selectedPizzaIngredients = [];
      selectedPizzaFlavors = [];
      comments = null;
      _showPizzaIngredients = false;
      _createTwoHalves = false;
      _updatePrice();
    });
  }

  Widget _buildVariantSelector(List<ProductVariant> variants) {
    if (variants.isEmpty) {
      return Container(); // No renderiza nada si no hay variantes
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Variantes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        for (var variant in variants)
          ListTile(
            title: Text(variant.shortName),
            trailing: Text('\$${variant.price!.toStringAsFixed(2)}'),
            selected: selectedVariant?.id ==
                variant.id, // Compara por ID o algún otro campo único
            selectedTileColor: Color.fromARGB(255, 33, 66,
                82), // Cambia el color de fondo cuando está seleccionado
            onTap: () {
              setState(() {
                selectedVariant = variant;
                _updatePrice(); // Actualiza el precio al seleccionar una variante
              });
            },
          ),
      ],
    );
  }

  void _deleteOrderItem() {
    // Obtiene el tempId del OrderItem existente
    final String? tempId = widget.existingOrderItem!.tempId;

    // Utiliza el Bloc para disparar el evento RemoveOrderItem
    BlocProvider.of<OrderCreationBloc>(context)
        .add(RemoveOrderItem(tempId: tempId!));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green, // Color de fondo verde
        content: Text(
          'Producto eliminado con éxito',
          style: TextStyle(
            fontSize: 20, // Fuente de tamaño 20
            fontWeight: FontWeight.bold, // Texto en negrita
          ),
        ),
        duration: Duration(milliseconds: 600),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildModifierTypeSection(ModifierType modifierType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(modifierType.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...(modifierType.modifiers?.map((modifier) => CheckboxListTile(
                  title: Text(modifier.shortName),
                  subtitle: Text('\$${modifier.price!.toStringAsFixed(2)}'),
                  value: selectedModifiers.any((selectedModifier) =>
                      selectedModifier.modifier?.id ==
                      modifier.id), // Compara por ID
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!modifierType.acceptsMultiple) {
                          // Elimina otros modificadores del mismo tipo si no se aceptan múltiples
                          selectedModifiers.removeWhere((selectedModifier) =>
                              modifierType.modifiers!.any((m) =>
                                  m.id == selectedModifier.modifier?.id));
                        }
                        selectedModifiers
                            .add(SelectedModifier(modifier: modifier));
                      } else {
                        selectedModifiers.removeWhere((selectedModifier) =>
                            selectedModifier.modifier?.id == modifier.id);
                      }
                      _updatePrice();
                    });
                  },
                )) ??
            []),
      ],
    );
  }

  Widget _buildPizzaFlavorSelector(List<PizzaFlavor> flavors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showPizzaIngredients) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Sabores de Pizza (2 máximo)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...flavors.map((flavor) => CheckboxListTile(
                title: Text(flavor.name),
                subtitle: flavor.price != null && flavor.price! > 0
                    ? Text('\$${flavor.price!.toStringAsFixed(2)}')
                    : null,
                value: selectedPizzaFlavors.any((selectedFlavor) =>
                    selectedFlavor.pizzaFlavor?.id == flavor.id),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (selectedPizzaFlavors.length < 2) {
                        selectedPizzaIngredients.clear();
                        selectedPizzaFlavors
                            .add(SelectedPizzaFlavor(pizzaFlavor: flavor));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Colors.orange, // color de fondo naranja
                            content:
                                Text('Solo puedes seleccionar hasta 2 sabores.',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                            duration: Duration(milliseconds: 600),
                          ),
                        );
                      }
                    } else {
                      selectedPizzaFlavors.removeWhere((selectedFlavor) =>
                          selectedFlavor.pizzaFlavor?.id == flavor.id);
                    }
                    _updatePrice(); // Actualiza el precio al seleccionar o deseleccionar un sabor
                  });
                },
              )),
        ],
      ],
    );
  }

  Widget _buildPizzaIngredientSelector(List<PizzaIngredient> ingredients) {
    Widget buildIngredientList(PizzaHalf half, String title) {
      return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            if (half == PizzaHalf.left) {
              _isLeftExpanded = !_isLeftExpanded;
            } else if (half == PizzaHalf.right) {
              _isRightExpanded = !_isRightExpanded;
            } else {
              _isIngredientsExpanded = !_isIngredientsExpanded;
            }
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return InkWell(
                onTap: () {
                  setState(() {
                    if (half == PizzaHalf.left) {
                      _isLeftExpanded = !_isLeftExpanded;
                    } else if (half == PizzaHalf.right) {
                      _isRightExpanded = !_isRightExpanded;
                    } else {
                      _isIngredientsExpanded = !_isIngredientsExpanded;
                    }
                  });
                },
                child: ListTile(
                  title: Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              );
            },
            body: Column(
              children: ingredients.map((ingredient) {
                // Buscar si el ingrediente ya está seleccionado
                final selectedIngredient = selectedPizzaIngredients.firstWhere(
                  (selected) =>
                      selected.pizzaIngredient?.id == ingredient.id &&
                      selected.half == half,
                  orElse: () => SelectedPizzaIngredient(
                      pizzaIngredient: ingredient,
                      half: half,
                      action: IngredientAction.add),
                );

                return Column(
                  children: [
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(ingredient.name),
                          ),
                          // Switch integrado en la misma línea
                          if (selectedPizzaIngredients.any((selected) =>
                              selected.pizzaIngredient?.id == ingredient.id &&
                              selected.half == half))
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Quitar', style: TextStyle(fontSize: 12)),
                                Switch(
                                  value: selectedIngredient.action ==
                                      IngredientAction.add,
                                  onChanged: (bool value) {
                                    setState(() {
                                      int index = selectedPizzaIngredients
                                          .indexWhere((selected) =>
                                              selected.pizzaIngredient?.id ==
                                                  ingredient.id &&
                                              selected.half == half);
                                      if (index != -1) {
                                        selectedPizzaIngredients[index] =
                                            SelectedPizzaIngredient(
                                          pizzaIngredient: ingredient,
                                          half: half,
                                          action: value
                                              ? IngredientAction.add
                                              : IngredientAction.remove,
                                        );
                                      }
                                      _updatePrice(); // Añadido para actualizar el precio
                                    });
                                  },
                                ),
                                Text('Añadir', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                        ],
                      ),
                      value: selectedPizzaIngredients.any((selected) =>
                          selected.pizzaIngredient?.id == ingredient.id &&
                          selected.half == half),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedPizzaIngredients
                                .add(SelectedPizzaIngredient(
                              pizzaIngredient: ingredient,
                              half: half,
                              action: IngredientAction.add,
                            ));
                          } else {
                            selectedPizzaIngredients.removeWhere((selected) =>
                                selected.pizzaIngredient?.id == ingredient.id &&
                                selected.half == half);
                          }
                          _updatePrice();
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            isExpanded: (half == PizzaHalf.left)
                ? _isLeftExpanded
                : (half == PizzaHalf.right)
                    ? _isRightExpanded
                    : _isIngredientsExpanded,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Ingredientes de Pizza',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (!_createTwoHalves)
          buildIngredientList(PizzaHalf.full, 'Ingredientes'),
        if (_createTwoHalves) ...[
          buildIngredientList(PizzaHalf.left, 'Primera mitad:'),
          buildIngredientList(PizzaHalf.right, 'Segunda mitad:'),
        ],
      ],
    );
  }

  double _calculatePrice() {
    double price = widget.product.price ?? 0.0;

    if (selectedVariant != null) {
      price += selectedVariant!.price!;
    }

    for (var selectedModifier in selectedModifiers) {
      price += selectedModifier.modifier?.price ?? 0.0;
    }

    if (selectedPizzaFlavors.length == 1) {
      price += selectedPizzaFlavors[0].pizzaFlavor?.price ?? 0.0;
    } else if (selectedPizzaFlavors.length == 2) {
      price += (selectedPizzaFlavors[0].pizzaFlavor?.price ?? 0.0) / 2;
      price += (selectedPizzaFlavors[1].pizzaFlavor?.price ?? 0.0) / 2;
    }

    if (_createTwoHalves) {
      // Calcular valor para mitad izquierda
      int leftIngredientsValue = selectedPizzaIngredients
          .where((ingredient) => ingredient.half == PizzaHalf.left)
          .map((ingredient) {
        int value = ingredient.pizzaIngredient?.ingredientValue ?? 0;
        return ingredient.action == IngredientAction.add ? value : -value;
      }).fold(0, (prev, element) => prev + element);

      // Calcular valor para mitad derecha
      int rightIngredientsValue = selectedPizzaIngredients
          .where((ingredient) => ingredient.half == PizzaHalf.right)
          .map((ingredient) {
        int value = ingredient.pizzaIngredient?.ingredientValue ?? 0;
        return ingredient.action == IngredientAction.add ? value : -value;
      }).fold(0, (prev, element) => prev + element);

      // Aplicar cargos extra si excede 4 ingredientes
      if (leftIngredientsValue > 4) {
        price += (leftIngredientsValue - 4) * 5.0;
      }
      if (rightIngredientsValue > 4) {
        price += (rightIngredientsValue - 4) * 5.0;
      }
    } else {
      // Calcular valor total para pizza completa
      int totalIngredientsValue = selectedPizzaIngredients.map((ingredient) {
        int value = ingredient.pizzaIngredient?.ingredientValue ?? 0;
        return ingredient.action == IngredientAction.add ? value : -value;
      }).fold(0, (prev, element) => prev + element);

      if (totalIngredientsValue > 4) {
        price += (totalIngredientsValue - 4) * 10.0;
      }
    }

    return price;
  }

  void _listen() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (val) => setState(() {
            comments = val.recognizedWords;
          }),
        );
      }
    } else {
      _speech.stop();
    }
  }
}
