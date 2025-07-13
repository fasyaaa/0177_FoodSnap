import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/components.dart';
import 'package:foody/core/constants/constants.dart';
import 'package:foody/data/models/request/auth/login_request_model.dart';
import 'package:foody/presentation/auth/bloc/login/login_bloc.dart';
import 'package:foody/presentation/home/admin/admin_home_screen.dart';
import 'package:foody/core/components/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController identityController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> _key;
  bool isShowPassword = false;

  @override
  void initState() {
    identityController = TextEditingController();
    passwordController = TextEditingController();
    _key = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    identityController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 100),

                /// Logo
                Center(
                  child: SvgPicture.asset(
                    'assets/images/onlylogo.svg',
                    height: 240,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Food Snap',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 48),

                // Email / Username
                CustomTextField(
                  controller: identityController,
                  label: 'Email or Username',
                  validator: "Email or Username can't be empty",
                ),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: passwordController,
                  label: 'Password',
                  validator: "Password can't be empty",
                  obscureText: !isShowPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isShowPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isShowPassword = !isShowPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    } else if (state is LoginSuccess) {
                      final role =
                          state.responseModel.data?.role?.toLowerCase();
                      final clientId = state.responseModel.data?.id;

                      if (!mounted) return;

                      if (role == 'admin') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminHomeScreen(),
                          ),
                          (route) => false,
                        );
                      } else if (role == 'client') {
                        if (clientId != null) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            arguments: clientId,
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Client ID not found'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unknown Role')),
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            state is LoginLoading
                                ? null
                                : () {
                                  if (_key.currentState!.validate()) {
                                    final request = LoginRequestModel(
                                      identity: identityController.text,
                                      password: passwordController.text,
                                    );
                                    context.read<LoginBloc>().add(
                                      LoginRequested(requestModel: request),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          state is LoginLoading ? 'Loading...' : 'Log in',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Create New Account Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
