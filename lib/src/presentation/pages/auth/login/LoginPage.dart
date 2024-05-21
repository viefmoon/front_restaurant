import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'bloc/LoginBloc.dart';
import 'LoginContent.dart';
import 'bloc/LoginEvent.dart';
import 'bloc/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc? _bloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
        body: SizedBox(
      width: double.infinity,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final responseState = state.response;
          if (responseState is Error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseState.message),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ));
          } else if (responseState is Success) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              final authResponse = responseState.data as AuthResponse;
              _bloc?.add(LoginSaveUserSession(authResponse: authResponse));

              final userRole = authResponse.user.roles?.isNotEmpty ?? false
                  ? authResponse.user.roles?.first.id ?? ''
                  : '';

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
                  destinationRoute = 'login';
                  break;
              }

              Navigator.pushNamedAndRemoveUntil(
                  context, destinationRoute, (route) => false);
            });
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
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
        }),
      ),
    ));
  }
}
