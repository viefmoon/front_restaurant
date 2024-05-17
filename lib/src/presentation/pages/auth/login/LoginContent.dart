import 'bloc/LoginBloc.dart';
import 'bloc/LoginEvent.dart';
import 'bloc/LoginState.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:restaurante/src/presentation/widgets/DefaultTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginContent extends StatelessWidget {
  LoginBloc? bloc;
  LoginState state;

  LoginContent(this.bloc, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Color.fromARGB(
                255, 206, 144, 73), // Establece el color de fondo a negro
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.3),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // VERTICAL
              crossAxisAlignment: CrossAxisAlignment.center, // HORIZANTAL
              children: [
                _textLogin(),
                _textFieldUsername(),
                _textFieldPassword(),
                _buttonLogin(context),
                _textDontHaveAccount(),
                _buttonGoToRegister(context),
                _buttonGoToSettings(context) // Added button to go to settings
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textLogin() {
    return Column(
      children: const [
        Text(
          'LA LEÑA',
          style: TextStyle(
              color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'INICIO DE SESION',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buttonGoToRegister(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, 'register');
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        child: Text(
          'REGISTRATE',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _textDontHaveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // HORIZANTAL
      children: [
        Container(
          width: 62,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(right: 5),
        ),
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        Container(
          width: 62,
          height: 1,
          color: Colors.white,
          margin: EdgeInsets.only(left: 5),
        ),
      ],
    );
  }

  Widget _buttonLogin(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        margin: EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 15),
        child: ElevatedButton(
          onPressed: () {
            if (state.formKey!.currentState!.validate()) {
              bloc?.add(LoginSubmit());
            } else {
              Fluttertoast.showToast(
                  msg: 'El formulario no es valido',
                  toastLength: Toast.LENGTH_LONG);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(
            'INICIAR SESION',
            style: TextStyle(color: Colors.black),
          ),
        ));
  }

  Widget _textFieldPassword() {
    return Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        child: DefaultTextField(
          label: 'Contraseña',
          color: Colors.black,
          icon: Icons.lock,
          // errorText: snapshot.error?.toString(),
          onChanged: (text) {
            bloc?.add(PasswordChanged(password: BlocFormItem(value: text)));
          },
          obscureText: true,
          validator: (value) {
            return state.password.error;
          },
        ));
  }

  Widget _textFieldUsername() {
    return Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        child: DefaultTextField(
          label: 'Nombre de usuario',
          color: Colors.black,
          icon: Icons.person,
          // errorText: snapshot.error?.toString(),
          onChanged: (text) {
            bloc?.add(UsernameChanged(username: BlocFormItem(value: text)));
          },
          validator: (value) {
            return state.username.error;
          },
        ));
  }

  Widget _buttonGoToSettings(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: EdgeInsets.only(left: 25, right: 25, top: 15),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context,
              'settings'); // Make sure '/settings' is the correct route for SettingsPage
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: Text(
          'CONFIGURACION',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
