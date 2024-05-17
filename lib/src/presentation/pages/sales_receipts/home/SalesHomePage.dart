import 'package:restaurante/main.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/DeliveryOrdersPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/PrintedOrdersPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/PendingOrderItemsPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/sales_options/SalesOptionsPage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales_report/SalesReportPage.dart';
import 'package:restaurante/src/presentation/pages/setting/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'bloc/SalesHomeBloc.dart';
import 'bloc/SalesHomeEvent.dart';
import 'bloc/SalesHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/ClosedOrdersPage.dart';

class SalesHomePage extends StatefulWidget {
  const SalesHomePage({super.key});

  @override
  State<SalesHomePage> createState() => _SalesHomePageState();
}

class _SalesHomePageState extends State<SalesHomePage> {
  SalesHomeBloc? _bloc;

  List<Widget> pageList = <Widget>[
    SalesOptionsPage(),
    PrintedOrdersPage(),
    DeliveryOrdersPage(),
    PendingOrderItemsPage(),
    ClosedOrdersPage(),
    SalesReportPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SalesHomeBloc>(context, listen: false);
    // Disparar el evento de inicialización para cargar el nombre de usuario
    BlocProvider.of<SalesHomeBloc>(context, listen: false).add(InitEvent());
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<SalesHomeBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('ORDENES', style: TextStyle(fontSize: 24)),
          iconTheme: IconThemeData(
            size: 40,
          ),
        ),
        drawer: BlocBuilder<SalesHomeBloc, SalesHomeState>(
          builder: (context, state) {
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(color: Colors.black),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.name ?? "Usuario",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          Text(
                            state.role ?? "Rol no disponible",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      )),
                  ListTile(
                    title: Text('Ventas', style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 0,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 0));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Tickets impresos',
                        style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 1,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 1));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Ordenes de entrega',
                        style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 2,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 2));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Productos pendientes',
                        style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 3,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 3));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Recibos', style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 4,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 4));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Informe de ventas',
                        style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 5,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 5));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title:
                        Text('Configuración', style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 6,
                    onTap: () {
                      _bloc?.add(SalesChangeDrawerPage(pageIndex: 6));
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                      height: 50), // Espaciado antes del botón de cerrar sesión
                  ListTile(
                    title:
                        Text('Cerrar sesión', style: TextStyle(fontSize: 22)),
                    onTap: () {
                      _bloc?.add(Logout());
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (route) => false);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        body: BlocBuilder<SalesHomeBloc, SalesHomeState>(
            builder: (context, state) {
          return pageList[state.pageIndex];
        }));
  }
}
