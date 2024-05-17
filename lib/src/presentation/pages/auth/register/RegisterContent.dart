import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:restaurante/src/presentation/utils/BlocFormItem.dart';
import 'package:restaurante/src/presentation/widgets/DefaultButton.dart';
import 'package:restaurante/src/presentation/widgets/DefaultIconBack.dart';
import 'package:restaurante/src/presentation/widgets/DefaultTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restaurante/src/domain/models/Role.dart';

class RegisterContent extends StatelessWidget {
  RegisterBloc? bloc;
  RegisterState state;

  RegisterContent(this.bloc, this.state);

  @override
  Widget build(BuildContext context) {
    final roles = state.roles ?? [];

    return Form(
      key: state.formKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Color.fromARGB(255, 206, 144, 73), // Cambia el fondo a negro
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.5),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 100,
                  ),
                  Text(
                    'REGISTRO',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Nombre',
                      color: Colors.black,
                      icon: Icons.person,
                      onChanged: (text) {
                        bloc?.add(RegisterNameChanged(
                            name: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.name.error;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Nombre de usuario',
                      color: Colors.black,
                      icon: Icons.person_outline,
                      onChanged: (text) {
                        bloc?.add(RegisterUsernameChanged(
                            username: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.username.error;
                      },
                    ),
                  ),
                  if (roles
                      .isNotEmpty) // Verificar si la lista de roles no está vacía
                    Container(
                      margin: EdgeInsets.only(
                          left: 25,
                          right:
                              25), // Ajustar los márgenes como en DefaultTextField
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value:
                              roles.any((role) => role.id == state.roleId.value)
                                  ? state.roleId.value
                                  : roles.first.id,
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            labelStyle: TextStyle(
                                color: Colors.black), // Estilo para la etiqueta
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15), // Ajustar el padding
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black), // Borde inferior blanco
                            ),
                            prefixIcon: Icon(Icons.group,
                                color: Colors.black), // Icono al inicio
                          ),
                          items:
                              roles.map<DropdownMenuItem<String>>((Role role) {
                            return DropdownMenuItem<String>(
                              value: role.id, // Usar el ID del rol como valor
                              child: Text(role.name,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors
                                          .black)), // Texto con color blanco
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              bloc?.add(RoleSelected(
                                  roleId: BlocFormItem(
                                      value:
                                          newValue))); // Pasar el ID del rol seleccionado
                            }
                          },
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.black), // Icono de dropdown
                          iconSize: 24, // Tamaño del icono
                          dropdownColor: Color.fromRGBO(255, 255, 255,
                              0.5), // Color de fondo del dropdown al expandirse
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: DefaultTextField(
                      label: 'Contraseña',
                      color: Colors.black,
                      icon: Icons.lock,
                      obscureText: true,
                      onChanged: (text) {
                        bloc?.add(RegisterPasswordChanged(
                            password: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.password.error;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25, top: 15),
                    child: DefaultButton(
                        text: 'REGISTRARSE',
                        color: Colors.black,
                        onPressed: () {
                          if (state.formKey!.currentState!.validate()) {
                            bloc?.add(RegisterFormSubmit());
                          } else {
                            Fluttertoast.showToast(
                                msg: 'El formulario no es valido',
                                toastLength: Toast.LENGTH_LONG);
                          }
                        }),
                  )
                ],
              ),
            ),
          ),
          DefaultIconBack(
            left: 55,
            top: 140,
          )
        ],
      ),
    );
  }
}
