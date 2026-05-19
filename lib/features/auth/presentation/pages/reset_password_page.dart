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
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const primaryColor = Color(0xFF005C45);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PasswordResetCubit>();
    String? email;
    // Check for arguments (passed via Navigator) - we expect email for OTP flow
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    bool isOtp = true;

    if (args != null) {
      email = args['email'];
      if (args['otp'] != null && _otpController.text.isEmpty) {
        _otpController.text = args['otp'];
      }
    }

    // Fallbacks: if no route args were provided, try to read the email from
    // the cubit's state (covers navigation paths that don't pass arguments).
    if (email == null) {
      if (cubit.state is PasswordResetOtpSent) {
        email = (cubit.state as PasswordResetOtpSent).email;
      } else if (cubit.state is PasswordResetEmailSent) {
        email = (cubit.state as PasswordResetEmailSent).email;
      } else if (cubit.state is PasswordResetCodeVerified) {
        final state = cubit.state as PasswordResetCodeVerified;
        email = state.email;
        if (_otpController.text.isEmpty) {
          _otpController.text = state.token;
        }
      }
    }

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
            if (state is PasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset successfully!")),
              );
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
              if (email == null) {
                return const Center(child: Text("Invalid session. Email is required."));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Set New Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create a strong new password to protect your account.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "OTP Code",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _otpController,
                        hint: "Enter OTP from email",
                        icon: Icons.lock_clock_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Code is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "New Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _passwordController,
                        hint: "********",
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 48),
                      PrimaryButton(
                        text: "Reset Password",
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<PasswordResetCubit>().resetPassword(
                                  email: email!,
                                  token: _otpController.text.trim(),
                                  newPassword: _passwordController.text.trim(),
                                  isOtp: true,
                                );
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
