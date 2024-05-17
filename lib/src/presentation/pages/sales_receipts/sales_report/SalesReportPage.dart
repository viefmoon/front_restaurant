import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/models/SalesReport.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/bloc/SalesReportBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/bloc/SalesReportEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/bloc/SalesReportState.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  @override
  void initState() {
    super.initState();
    final SalesReportBloc bloc =
        BlocProvider.of<SalesReportBloc>(context, listen: false);
    bloc.add(LoadSalesReport());
  }

  @override
  Widget build(BuildContext context) {
    final SalesReportBloc bloc = BlocProvider.of<SalesReportBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Informe de Ventas'),
      ),
      body: BlocBuilder<SalesReportBloc, SalesReportState>(
        builder: (context, state) {
          if (state.response is Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.response is Success) {
            SalesReport salesReport = state.salesReport!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de Ventas: ${salesReport.totalSales}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Total Monto Pagado: \$${salesReport.totalAmountPaid.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  Expanded(
                    child: ListView.builder(
                      itemCount: salesReport.subcategories.length,
                      itemBuilder: (context, index) {
                        SubcategorySales subcategory =
                            salesReport.subcategories[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subcategory.subcategoryName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Total de Ventas: ${subcategory.totalSales}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: subcategory.products.length,
                              itemBuilder: (context, productIndex) {
                                ProductSales product =
                                    subcategory.products[productIndex];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(product.name,
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                        'Cantidad: ${product.quantity}, Total: \$${product.totalSales.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state.response is Error) {
            return Center(
              child: Text('Error: ${(state.response as Error).message}'),
            );
          } else {
            return Center(
              child: Text('No hay datos de informe de ventas disponibles.'),
            );
          }
        },
      ),
    );
  }
}
