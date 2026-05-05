import 'package:complaint_resolution_app/core/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/auth/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF005C45);

    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Registration successful")),
                );

                // TODO: Navigate to home page
                Navigator.pushNamed(context, RouteNames.login);
              }

              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),

                          /// Title
                          const Text(
                            "Register",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 40),

                          /// Email
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _emailController,
                            hint: "Ex: abc@example.com",
                            icon: Icons.alternate_email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              final emailReg = RegExp(
                                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}",
                              );
                              if (!emailReg.hasMatch(value.trim())) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          /// Name
                          const Text(
                            "Your Name",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _nameController,
                            hint: "Ex. Saul Ramirez",
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          /// Password
                          const Text(
                            "Your Password",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthTextField(
                            controller: _passwordController,
                            hint: "********",
                            icon: Icons.lock_outline,
                            obscure: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Minimum 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          /// Register Button
                          PrimaryButton(
                            text: "Register",
                            isLoading: state is AuthLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().register(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Login redirect
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Already have an account? Login",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
