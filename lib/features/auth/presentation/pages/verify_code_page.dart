import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/password_reset/password_reset_cubit.dart';
import '../cubit/password_reset/password_reset_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const primaryColor = Color(0xFF005C45);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PasswordResetCubit>();
    String email = "";
    
    if (cubit.state is PasswordResetEmailSent) {
      email = (cubit.state as PasswordResetEmailSent).email;
    } else if (cubit.state is PasswordResetOtpSent) {
      email = (cubit.state as PasswordResetOtpSent).email;
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
            if (state is PasswordResetCodeVerified) {
              Navigator.pushReplacementNamed(context, RouteNames.resetPassword);
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
                      const Text(
                        "Verify Code",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We've sent a 6-digit verification code to $email. Please enter it below to continue.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Verification Code",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _codeController,
                        hint: "Enter 6-digit code",
                        icon: Icons.lock_clock_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Code is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: "Verify Code",
                        isLoading: state is PasswordResetLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<PasswordResetCubit>()
                                .verifyCode(email, _codeController.text.trim());
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                             // Logic to resend code could go here
                          },
                          child: const Text(
                            "Didn't receive code? Resend",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
