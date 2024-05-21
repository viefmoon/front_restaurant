import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PhoneNumberInputPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  late stt.SpeechToText _speech;

  PhoneNumberInputPage() {
    _speech = stt.SpeechToText();
  }

  void _listenForPhoneNumber(BuildContext context) async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          _phoneController.text = result.recognizedWords.replaceAll(' ', '');
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El micrófono no está disponible."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmPhoneNumber(BuildContext context) {
    if (_speech.isListening) {
      _speech.stop();
    }
    BlocProvider.of<OrderCreationBloc>(context).add(
      PhoneNumberEntered(phoneNumber: _phoneController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width:
                    double.infinity, // Hace que la caja de texto sea más grande
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                    border:
                        OutlineInputBorder(), // Añade un borde a la caja de texto
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () => _listenForPhoneNumber(context),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 30), // Espacio entre el TextField y el botón
              SizedBox(
                width: double.infinity, // Hace que el botón sea más grande
                height: 80, // Aumenta la altura del botón
                child: ElevatedButton(
                  onPressed: () {
                    _confirmPhoneNumber(context);
                  },
                  child: Text('Continuar',
                      style: TextStyle(
                          fontSize: 30)), // Aumenta el tamaño del texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
