import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foody/core/components/components.dart';
import 'package:foody/core/components/spaces.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/request/auth/register_request_model.dart';
import 'package:foody/presentation/auth/bloc/register/register_bloc.dart';
import 'package:foody/presentation/auth/login_screen.dart';
import 'package:foody/presentation/home/client/client_home_screen.dart';
import 'package:foody/core/components/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController namaController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> _key;
  bool isShowPassword = false;

  @override
  void initState() {
    namaController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _key = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    namaController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label.toLowerCase(),
      labelStyle: const TextStyle(color: AppColors.light),
      filled: true,
      fillColor: AppColors.grey.withOpacity(0.4),
      hintText: label.toLowerCase(),
      hintStyle: const TextStyle(color: AppColors.light),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset('assets/images/onlylogo.svg', height: 70);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SpaceHeight(60),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/iconsBack.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  logo,
                  const SizedBox(width: 10),
                  const Text(
                    'Food Snap',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SpaceHeight(40),
              // Name
              CustomTextField(
                controller: namaController,
                label: 'Name',
                validator: "Name can't be empty",
              ),

              const SpaceHeight(20),

              // Username
              CustomTextField(
                controller: usernameController,
                label: 'Username',
                validator: "Username can't be empty",
              ),

              const SpaceHeight(20),

              // Email
              CustomTextField(
                controller: emailController,
                label: 'Email',
                validator: "Email can't be empty",
              ),

              const SpaceHeight(20),

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

              const SpaceHeight(40),
              BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientHomeScreen(),
                      ),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else if (state is RegisterFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state is RegisterLoading
                              ? null
                              : () {
                                if (_key.currentState!.validate()) {
                                  final request = RegisterRequestModel(
                                    name: namaController.text,
                                    username: usernameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  context.read<RegisterBloc>().add(
                                    RegisterRequested(requestModel: request),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        state is RegisterLoading ? 'Loading...' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SpaceHeight(20),
              Text.rich(
                TextSpan(
                  text: 'Have an Account? ',
                  style: const TextStyle(color: AppColors.grey),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(color: AppColors.primary),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SpaceHeight(20),
            ],
          ),
        ),
      ),
    );
  }
}
