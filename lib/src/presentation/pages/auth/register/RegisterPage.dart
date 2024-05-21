import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/auth/register/RegisterContent.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:restaurante/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<RegisterBloc>(context);
    _bloc?.add(LoadRoles()); // Cargar los roles al iniciar
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<RegisterBloc>(context);

    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: BlocListener<RegisterBloc, RegisterState>(
                listener: (context, state) {
              final responseState = state.response;
              if (responseState is Error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(responseState.message),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ));
              } else if (responseState is Success) {
                _bloc?.add(RegisterFormReset());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Registro exitoso'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ));
              }
            }, child: BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
              return RegisterContent(_bloc, state);
            }))));
  }
}
