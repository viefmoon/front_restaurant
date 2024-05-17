import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/ProductPersonalizationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationState.dart';
import 'package:uuid/uuid.dart';

class ProductSelectionPage extends StatelessWidget {
  const ProductSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderCreationBloc bloc = BlocProvider.of<OrderCreationBloc>(context);

    return Scaffold(
      body: BlocBuilder<OrderCreationBloc, OrderCreationState>(
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
      OrderCreationBloc bloc, OrderCreationState state) {
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
      OrderCreationBloc bloc, OrderCreationState state) {
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

  Widget _buildProductButtons(
      OrderCreationBloc bloc, OrderCreationState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
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
                (product.productObservationTypes?.isNotEmpty ?? false) ||
                (product.pizzaFlavors?.isNotEmpty ?? false) ||
                (product.pizzaIngredients?.isNotEmpty ?? false);

        return InkWell(
          onTap: () {
            if (!requiresPersonalization) {
              final tempId = Uuid().v4();
              final orderItem = OrderItem(
                tempId: tempId,
                product: Product(
                  id: product.id,
                  name: product.name,
                  price: product.price,
                ),
                status: OrderItemStatus.created,
                price: product.price,
              );
              bloc.add(AddOrderItem(orderItem: orderItem));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Producto agregado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: Duration(milliseconds: 150),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductPersonalizationPage(
                        product: product, bloc: bloc, state: state)),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
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
                      return Center(
                        child: Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color.fromARGB(221, 112, 71, 71),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                Container(
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
                        product.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!requiresPersonalization && productCount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: Colors.white, size: 40),
                              onPressed: () {
                                final tempId = state.orderItems!
                                    .where((item) =>
                                        item.product?.id == product.id)
                                    .first
                                    .tempId!;
                                bloc.add(RemoveOrderItem(tempId: tempId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Producto quitado',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 150),
                                  ),
                                );
                              },
                            ),
                            Text(
                              productCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add,
                                  color: Colors.white, size: 40),
                              onPressed: () {
                                final tempId = Uuid().v4();
                                final orderItem = OrderItem(
                                  tempId: tempId,
                                  product: Product(
                                    id: product.id,
                                    name: product.name,
                                    price: product.price,
                                  ),
                                  status: OrderItemStatus.created,
                                  price: product.price,
                                );
                                bloc.add(AddOrderItem(orderItem: orderItem));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Producto agregado',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 150),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (requiresPersonalization && productCount > 0)
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
