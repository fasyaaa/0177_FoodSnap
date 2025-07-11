import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/data/repository/auth_repository.dart';
import 'package:foody/presentation/auth/bloc/login/login_bloc.dart';
import 'package:foody/presentation/auth/bloc/register/register_bloc.dart';
import 'package:foody/presentation/auth/bloc/login_screen.dart';
import 'package:foody/presentation/auth/bloc/register_screen.dart';
import 'package:foody/service/service_http_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(ServiceHttpClient());

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(authRepository: authRepository),
        ),
        BlocProvider<RegisterBloc>(
          create: (_) => RegisterBloc(authRepository: authRepository),
        ),
      ],
      child: MaterialApp(
        title: 'FoodSnap',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}
