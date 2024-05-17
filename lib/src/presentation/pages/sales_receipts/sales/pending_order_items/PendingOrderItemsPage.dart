import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/bloc/PendingOrderItemsBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/bloc/PendingOrderItemsEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/bloc/PendingOrderItemsState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingOrderItemsPage extends StatefulWidget {
  @override
  _PendingOrderItemsPageState createState() => _PendingOrderItemsPageState();
}

class _PendingOrderItemsPageState extends State<PendingOrderItemsPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PendingOrderItemsBloc>(context)
        .add(LoadPendingOrderItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos Pendientes de Preparación'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: 35, // Aumenta el tamaño del icono aquí
            onPressed: () {
              BlocProvider.of<PendingOrderItemsBloc>(context)
                  .add(RefreshPendingOrderItems());
            },
          ),
        ],
      ),
      body: BlocBuilder<PendingOrderItemsBloc, PendingOrderItemsState>(
        builder: (context, state) {
          if (state is PendingOrderItemsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PendingOrderItemsLoaded) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ExpansionTile(
                  title: Text(item.subcategoryName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  children: item.products
                      .map((product) => ListTile(
                            title: Text(
                              product.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text('${product.count}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ))
                      .toList(),
                );
              },
            );
          } else if (state is PendingOrderItemsError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('No hay items pendientes.'));
          }
        },
      ),
    );
  }
}
