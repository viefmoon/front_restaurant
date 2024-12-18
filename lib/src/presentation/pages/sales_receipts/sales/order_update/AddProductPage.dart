import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/UpdateProductPersonalizationPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateEvent.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OrderUpdateBloc bloc = BlocProvider.of<OrderUpdateBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Productos'), // Título de tu preferencia
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Permite volver atrás
        ),
      ),
      body: BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
        builder: (context, state) {
          if (state.categories != null && state.categories!.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  flex: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: state.categories!.map((category) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: AspectRatio(
                            aspectRatio: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                bloc.add(
                                    CategorySelected(categoryId: category.id));
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(category.name,
                                  style: TextStyle(fontSize: 40)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: state.selectedCategoryId != null
                      ? _buildContentBasedOnSelection(bloc, state)
                      : Container(),
                ),
              ],
            );
          } else if (state.response is Loading) {
            return Center(child: CircularProgressIndicator(strokeWidth: 8.0));
          } else {
            return Center(child: Text('No se encontraron categorías'));
          }
        },
      ),
    );
  }

  Widget _buildContentBasedOnSelection(
      OrderUpdateBloc bloc, OrderUpdateState state) {
    if (state.selectedSubcategoryId != null &&
        state.filteredProducts != null &&
        state.filteredProducts!.isNotEmpty) {
      // Muestra productos si una subcategoría está seleccionada y hay productos disponibles
      return _buildProductButtons(bloc, state);
    } else {
      // De lo contrario, muestra subcategorías
      return _buildSubcategoryButtons(bloc, state);
    }
  }

  Widget _buildSubcategoryButtons(
      OrderUpdateBloc bloc, OrderUpdateState state) {
    if (state.filteredSubcategories != null &&
        state.filteredSubcategories!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
          ),
          itemCount: state.filteredSubcategories!.length,
          itemBuilder: (context, index) {
            final subcategory = state.filteredSubcategories![index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(SubcategorySelected(subcategoryId: subcategory.id));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(subcategory.name, style: TextStyle(fontSize: 22)),
              ),
            );
          },
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildProductButtons(OrderUpdateBloc bloc, OrderUpdateState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: state.filteredProducts!.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts![index];
        final hasImage =
            product.imageUrl != null && product.imageUrl!.isNotEmpty;
        final productCount = state.orderItems
                ?.where((item) => item.product?.id == product.id)
                .length ??
            0;

        bool requiresPersonalization =
            (product.productVariants?.isNotEmpty ?? false) ||
                (product.modifierTypes?.isNotEmpty ?? false) ||
                (product.pizzaFlavors?.isNotEmpty ?? false) ||
                (product.pizzaIngredients?.isNotEmpty ?? false);

        return InkWell(
          onTap: () {
            if (!requiresPersonalization) {
              final tempId = Uuid().v4();

              final orderItem = OrderItem(
                tempId: tempId, // Asigna el nuevo tempId generado
                product: product,
                id: null,
                status: OrderItemStatus.created,
                comments: null,
                order: null,
                productVariant: null,
                selectedModifiers: [],
                selectedPizzaFlavors: [],
                selectedPizzaIngredients: [],
                price: product.price,
                orderItemUpdates: [],
              );

              bloc.add(AddOrderItem(orderItem: orderItem));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Producto agregado',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  duration: Duration(milliseconds: 150),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateProductPersonalizationPage(
                        product: product, bloc: bloc, state: state)),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200], // Fondo para productos sin imagen
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasImage)
                  Image.asset(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback al nombre del producto si la imagen no se puede cargar
                      return Center(
                        child: Text(
                          product.shortName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color.fromARGB(221, 112, 71, 71),
                            fontSize: 30,
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  // Agrega un degradado para mejorar la legibilidad del texto sobre la imagen
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.99),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        product.shortName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (productCount > 0)
                        Text(
                          productCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      shrinkWrap: true,
    );
  }
}
