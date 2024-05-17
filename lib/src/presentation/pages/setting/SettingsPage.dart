import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsPage> {
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OrdersRepository ordersRepository;
  late AuthUseCases authUseCases;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    ordersRepository = GetIt.instance.get<OrdersRepository>();
    authUseCases = GetIt.instance.get<AuthUseCases>();
    _loadServerIP();
    _determineUserRole();
  }

  Future<void> _determineUserRole() async {
    AuthResponse? userSession = await authUseCases.getUserSession.run();
    setState(() {
      _userRole = userSession?.user.roles?.isNotEmpty == true
          ? userSession?.user.roles!.first.name
          : null;
    });
  }

  _loadServerIP() async {
    final prefs = await SharedPreferences.getInstance();
    String serverIP = prefs.getString('serverIP') ?? '192.168.100.32';
    _ipController.text = serverIP;
  }

  _saveServerIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('serverIP', _ipController.text);
      _showSnackBar('Dirección IP guardada con éxito', true);
    } catch (e) {
      _showSnackBar('Error al guardar la dirección IP', false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Dirección IP del Servidor',
                labelStyle: TextStyle(fontSize: 26),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _saveServerIP();
                },
                child: Text('Guardar', style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            if (_userRole == "Administrador")
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController passwordController =
                            TextEditingController();
                        return AlertDialog(
                          title: Text('Confirmación de reseteo'),
                          content: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Ingrese contraseña para resetear',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Aceptar'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                if (passwordController.text == "root") {
                                  var result =
                                      await ordersRepository.resetDatabase();
                                  if (result is Success) {
                                    _showSnackBar(
                                        'La base de datos ha sido reseteada.',
                                        true);
                                  } else {
                                    _showSnackBar(
                                        'Error al resetear la base de datos.',
                                        false);
                                  }
                                } else {
                                  _showSnackBar(
                                      'Contraseña incorrecta.', false);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Resetear Base de Datos',
                      style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
