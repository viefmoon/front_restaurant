import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'bloc/LoginBloc.dart';
import 'LoginContent.dart';
import 'bloc/LoginEvent.dart';
import 'bloc/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc? _bloc;

  @override
  void initState() {
    // EJECUTA UNA SOLA VEZ CUANDO CARGA LA PANTALLA
    super.initState();
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   _loginBlocCubit?.dispose();
    // });
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
        body: SizedBox(
      width: double.infinity,
      child: BlocListener<LoginBloc, LoginState>(listener: (context, state) {
        final responseState = state.response;
        if (responseState is Error) {
          Fluttertoast.showToast(
              msg: responseState.message, toastLength: Toast.LENGTH_LONG);
        } else if (responseState is Success) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final authResponse = responseState.data as AuthResponse;
            _bloc?.add(LoginSaveUserSession(authResponse: authResponse));

            // Determinar el rol del usuario
            final userRole = authResponse.user.roles?.isNotEmpty ?? false
                ? authResponse.user.roles?.first.id ??
                    '' // Accediendo a la propiedad `.id`
                : '';

            // Definir el destino según el rol
            String destinationRoute;
            switch (userRole) {
              case 'ADMIN':
                destinationRoute = 'salesHome';
                break;
              case 'WAITER':
                destinationRoute = 'waiterHome';
                break;
              case 'PIZZA_CHEF':
                destinationRoute = 'pizzaHome';
                break;
              case 'HAMBURGER_CHEF':
                destinationRoute = 'hamburgerHome';
                break;
              case 'KITCHEN_CHEF':
                destinationRoute = 'kitchenHome';
                break;
              case 'BAR_CHEF':
                destinationRoute = 'barHome';
                break;
              default:
                destinationRoute =
                    'login'; // Redirigir a login o a una página de error si el rol no es reconocido
                break;
            }

            // Redirigir al usuario a la página correspondiente
            Navigator.pushNamedAndRemoveUntil(
                context, destinationRoute, (route) => false);
          });
        }
      }, child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        final responseState = state.response;
        if (responseState is Loading) {
          return Stack(
            children: [
              LoginContent(_bloc, state),
              Center(child: CircularProgressIndicator())
            ],
          );
        }
        return LoginContent(_bloc, state);
      })),
    ));
  }
}
