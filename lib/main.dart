import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/data/repository/auth_repository.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/data/repository/comment_repository.dart';
import 'package:foody/presentation/auth/bloc/login/login_bloc.dart';
import 'package:foody/presentation/auth/bloc/register/register_bloc.dart';
import 'package:foody/presentation/auth/login_screen.dart';
import 'package:foody/presentation/auth/register_screen.dart';
import 'package:foody/presentation/home/client/bloc/client_home_bloc.dart';
import 'package:foody/presentation/home/client/client_home_screen.dart';
import 'package:foody/service/service_http_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = ServiceHttpClient();
    final authRepository = AuthRepository(httpClient);
    final feedRepository = FeedRepository(httpClient);
    final commentRepository = CommentRepository(httpClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(authRepository: authRepository),
        ),
        BlocProvider<RegisterBloc>(
          create: (_) => RegisterBloc(authRepository: authRepository),
        ),
        BlocProvider<ClientHomeBloc>(
          create: (_) => ClientHomeBloc(feedRepository, commentRepository)..add(LoadFeeds()),
        ),
      ],
      child: MaterialApp(
        title: 'FoodSnap',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
         '/home': (context) => const ClientHomeScreen(),
        },
      ),
    );
  }
}
