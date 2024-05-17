import 'package:restaurante/src/presentation/pages/preparation/bar/home/BarHomePage.dart';
import 'package:restaurante/src/presentation/pages/preparation/burger/home/BurgerHomePage.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/home/PizzaHomePage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home/SalesHomePage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/home_waiter/WaiterHomePage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/OrderCreationContainer.dart';
import 'package:restaurante/src/presentation/pages/setting/SettingsPage.dart';
import 'injection.dart';
import 'src/blocProviders.dart';
import 'src/presentation/pages/auth/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restaurante/src/presentation/pages/auth/register/RegisterPage.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Definición del tema personalizado
    final ThemeData theme = ThemeData(
      useMaterial3: true, // Habilita Material 3
      colorScheme: ColorScheme.fromSeed(
        seedColor:
            Colors.brown, // Color semilla utilizado para generar la paleta
        brightness: Brightness.dark, // Prefiere el modo claro
        primary: Colors.white, // Color principal para elementos interactivos
        secondary:
            Colors.blueGrey, // Color secundario para complementar al principal
        error: Colors.redAccent, // Color para indicaciones de errores
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850], // Color de fondo para la AppBar
        foregroundColor:
            Colors.orange, // Color del texto y los iconos en la AppBar
      ),

      // Añade más personalizaciones según sea necesario
    );

    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(
        builder: FToastBuilder(),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme, // Usa el tema personalizado aquí
        initialRoute: 'login',
        routes: {
          'login': (BuildContext context) => LoginPage(),
          'register': (BuildContext context) => RegisterPage(),
          'salesHome': (BuildContext context) => SalesHomePage(),
          'waiterHome': (BuildContext context) => WaiterHomePage(),
          'order/create': (BuildContext context) => OrderCreationContainer(),
          'hamburgerHome': (BuildContext context) => BurgerHomePage(),
          'pizzaHome': (BuildContext context) => PizzaHomePage(),
          'barHome': (BuildContext context) => BarHomePage(),
          'settings': (BuildContext context) =>
              SettingsPage(), // Added route for SettingsPage
        },
      ),
    );
  }
}
