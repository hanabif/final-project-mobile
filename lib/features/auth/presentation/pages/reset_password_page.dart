import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/password_reset/password_reset_cubit.dart';
import '../cubit/password_reset/password_reset_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const primaryColor = Color(0xFF005C45);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PasswordResetCubit>();
    final state = cubit.state as PasswordResetCodeVerified;
    final email = state.email;

    return Scaffold(
      body: SafeArea(
        child: BlocListener<PasswordResetCubit, PasswordResetState>(
          listener: (context, state) {
            if (state is PasswordResetSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (route) => false,
              );
            }

            if (state is PasswordResetError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<PasswordResetCubit, PasswordResetState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Set your new password to login into your account!",
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 40),
                      const Text("Enter password",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      AuthTextField(
                        controller: _passwordController,
                        hint: "********",
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("Confirm password",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      AuthTextField(
                        controller: _confirmController,
                        hint: "********",
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: "Submit",
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<PasswordResetCubit>().resetPassword(
                                  email,
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}