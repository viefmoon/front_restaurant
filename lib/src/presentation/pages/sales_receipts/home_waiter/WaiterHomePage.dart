import 'package:restaurante/main.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/sales_options/SalesOptionsPage.dart';
import 'package:restaurante/src/presentation/pages/setting/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'bloc/WaiterHomeBloc.dart';
import 'bloc/WaiterHomeEvent.dart';
import 'bloc/WaiterHomeState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaiterHomePage extends StatefulWidget {
  const WaiterHomePage({super.key});

  @override
  State<WaiterHomePage> createState() => _WaiterHomePageState();
}

class _WaiterHomePageState extends State<WaiterHomePage> {
  WaiterHomeBloc? _bloc;

  List<Widget> pageList = <Widget>[
    SalesOptionsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<WaiterHomeBloc>(context, listen: false);
    // Disparar el evento de inicialización para cargar el nombre de usuario
    BlocProvider.of<WaiterHomeBloc>(context, listen: false).add(InitEvent());
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<WaiterHomeBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('ORDENES', style: TextStyle(fontSize: 24)),
          iconTheme: IconThemeData(
            size: 40,
          ),
        ),
        drawer: BlocBuilder<WaiterHomeBloc, WaiterHomeState>(
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
                      _bloc?.add(WaiterChangeDrawerPage(pageIndex: 0));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title:
                        Text('Configuración', style: TextStyle(fontSize: 22)),
                    selected: state.pageIndex == 1,
                    onTap: () {
                      _bloc?.add(WaiterChangeDrawerPage(pageIndex: 1));
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
        body: BlocBuilder<WaiterHomeBloc, WaiterHomeState>(
            builder: (context, state) {
          return pageList[state.pageIndex];
        }));
  }
}
