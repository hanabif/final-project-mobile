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
  String _selectedMethod = 'otp'; // 'otp' or 'link'

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
                if (_selectedMethod == 'otp') {
                  Navigator.pushNamed(
                    context,
                    RouteNames.verifyCode,
                  );
                } else {
                   _showSuccessDialog(context);
                }
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
                        const SizedBox(height: 32),
                        const Text(
                          "Reset Method",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMethodCard(
                          id: 'otp',
                          title: "Verification Code",
                          subtitle: "Receive a 6-digit code via email",
                          icon: Icons.security_outlined,
                          isSelected: _selectedMethod == 'otp',
                        ),
                        const SizedBox(height: 16),
                        _buildMethodCard(
                          id: 'link',
                          title: "Magic Reset Link",
                          subtitle: "Password reset link sent via email",
                          icon: Icons.auto_awesome_outlined,
                          isSelected: _selectedMethod == 'link',
                        ),
                        const SizedBox(height: 48),
                        PrimaryButton(
                          text: "Send Request",
                          isLoading: state is PasswordResetLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final email = _emailController.text.trim();
                              if (_selectedMethod == 'otp') {
                                context.read<PasswordResetCubit>().sendResetOtp(email);
                              } else {
                                context.read<PasswordResetCubit>().sendResetEmail(email);
                              }
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

  Widget _buildMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primaryColor : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Email Sent", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text(
          "We've sent a magic reset link to your email. Please check your inbox and click the link to reset your password.",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to Login", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
