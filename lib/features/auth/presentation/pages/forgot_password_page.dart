import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/password_reset/password_reset_cubit.dart';
import '../cubit/password_reset/password_reset_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  final bool isChangePassword;
  const ForgotPasswordPage({super.key, this.isChangePassword = false});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const primaryColor = Color(0xFF005C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: BlocListener<PasswordResetCubit, PasswordResetState>(
            listener: (context, state) {
              if (state is PasswordResetEmailSent || state is PasswordResetOtpSent) {
                Navigator.pushNamed(
                  context,
                  RouteNames.resetPassword,
                  arguments: {'email': _emailController.text.trim()},
                );
              }

              if (state is PasswordResetError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<PasswordResetCubit, PasswordResetState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          widget.isChangePassword ? "Change Password" : "Forgot Password?",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Don't worry! It happens. Please select the method you'd like to use to reset your password.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Enter Email Address",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          controller: _emailController,
                          hint: "example@email.com",
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),
                        PrimaryButton(
                          text: "Send Request",
                          isLoading: state is PasswordResetLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text.trim();
                              context.read<PasswordResetCubit>().sendResetEmail(email);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
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
