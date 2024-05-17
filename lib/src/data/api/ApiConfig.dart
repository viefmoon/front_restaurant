import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String _api = "192.168.100.32:3000"; // Valor por defecto

  static Future<String> getApiEcommerce() async {
    final prefs = await SharedPreferences.getInstance();
    String serverIP = prefs.getString('serverIP') ?? "192.168.100.32";
    // Concatena el puerto aquí
    _api = "$serverIP:3000";
    return _api;
  }
}
