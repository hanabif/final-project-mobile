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
    final state = cubit.state as PasswordResetEmailSent;
    final email = state.email;

    return Scaffold(
      body: SafeArea(
        child: BlocListener<PasswordResetCubit, PasswordResetState>(
          listener: (context, state) {
            if (state is PasswordResetCodeVerified) {
              Navigator.pushNamed(context, RouteNames.resetPassword);
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
                        "Verify code",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "We have sent an email to your email account with a verification code!",
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Verification code",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      AuthTextField(
                        controller: _codeController,
                        hint: "Enter code",
                        icon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Code is required";
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
                            context
                                .read<PasswordResetCubit>()
                                .verifyCode(email, _codeController.text.trim());
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