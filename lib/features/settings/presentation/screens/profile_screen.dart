import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_bottom_navigation_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../../../complaint/presentation/cubits/profile/profile_cubit.dart';
import '../widgets/settings_item.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProfileCubit>()..loadProfileData(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: l10n.profile,
          showBackButton: true,
          showThemeToggle: true,
          showNotification: true,
          backgroundColor: const Color(0xFF005C45),
        ),
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
              );
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.passwordChangedSuccessfully)),
              );
            }
          },
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  if (profileState is ProfileLoading ||
                      settingsState is SettingsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (profileState is ProfileError) {
                    return Center(child: Text(profileState.message));
                  } else if (settingsState is SettingsError) {
                    return Center(child: Text(settingsState.message));
                  } else if (profileState is ProfileLoaded &&
                      settingsState is SettingsLoaded) {
                    final settings = settingsState.settings;
                    final user = profileState.user;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          _buildSectionContainer(
                            context: context,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // My Complaints
                        Text(
                          l10n.myComplaints,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSectionContainer(
                          context: context,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    RouteNames.complaintList,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF005C45),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(l10n.viewAllComplaints),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account Settings
                        Text(
                          l10n.accountSettings,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSectionContainer(
                          context: context,
                          child: Column(
                            children: [
                              SettingsItem(
                                icon: Icons.edit_outlined,
                                title: l10n.editProfile,
                                onTap: () => _showEditProfileDialog(
                                  context,
                                  user.name,
                                  context.read<ProfileCubit>(),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.lock_outline,
                                title: l10n.changePassword,
                                onTap: () => _showChangePasswordDialog(
                                  context,
                                  context.read<ProfileCubit>(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Preferences
                        Text(
                          l10n.preferences,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSectionContainer(
                          context: context,
                          child: Column(
                            children: [
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                leading: const Icon(
                                  Icons.language,
                                  color: Color(0xFFFCD703),
                                ),
                                title: Text(
                                  l10n.language,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  settings.language,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                children: [
                                  _LanguageOptionTile(
                                      label: l10n.english,
                                    selected:
                                        _normalizeLanguage(settings.language) ==
                                        l10n.english,
                                    onTap: () => context
                                        .read<SettingsCubit>()
                                        .setLanguage(l10n.english),
                                  ),
                                  const SizedBox(height: 8),
                                  _LanguageOptionTile(
                                      label: l10n.amharic,
                                    selected:
                                        _normalizeLanguage(settings.language) ==
                                        l10n.amharic,
                                    onTap: () => context
                                        .read<SettingsCubit>()
                                        .setLanguage(l10n.amharic),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.logout),
                          ),
                        ),
                        const SizedBox(height: 80), // Space for bottom nav
                      ],
                    ),
                  );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
        bottomNavigationBar: _BottomNavBar(),
        floatingActionButton: _FloatingReportButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildSectionContainer({
    required Widget child,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    String currentName,
    ProfileCubit profileCubit,
  ) {
    final nameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocBuilder<ProfileCubit, ProfileState>(
        bloc: profileCubit,
        builder: (context, state) {
          bool isLoading = state is ProfileLoading;
          final l10n = AppLocalizations.of(context)!;

          return AlertDialog(
            title: Text(l10n.editProfile),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Form(
                    key: formKey,
                    child: TextFormField(
                      enabled: !isLoading,
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.nameIsRequired;
                        }
                        return null;
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          profileCubit
                              .updateProfile(nameController.text)
                              .then((_) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.update),
              ),
            ],
          );
        },
      ),
    );
  }

  String _normalizeLanguage(String language) {
    final value = language.toLowerCase();
    if (value.contains('am')) {
      return 'Amharic';
    }
    return 'English';
  }

  void _showChangePasswordDialog(
    BuildContext context,
    ProfileCubit profileCubit,
  ) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocBuilder<ProfileCubit, ProfileState>(
        bloc: profileCubit,
        builder: (context, state) {
          bool isLoading = state is ProfileLoading;
          final l10n = AppLocalizations.of(context)!;

          return AlertDialog(
            title: Text(l10n.changePassword),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          enabled: !isLoading,
                          controller: oldPasswordController,
                          decoration: InputDecoration(
                            labelText: l10n.currentPassword,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.currentPasswordIsRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: !isLoading,
                          controller: newPasswordController,
                          decoration: InputDecoration(
                            labelText: l10n.newPassword,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.newPasswordIsRequired;
                            }
                            if (value.length < 6) {
                              return l10n.passwordMustBeAtLeast6Characters;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: !isLoading,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: l10n.confirmPassword,
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseConfirmPassword;
                            }
                            if (value != newPasswordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          profileCubit
                              .changePassword(
                                oldPasswordController.text,
                                newPasswordController.text,
                              )
                              .then((_) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(
          l10n.areYouSureLogout,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Clear session and call logout endpoint
              await sl<LogoutUseCase>()();
              
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFFCD703).withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(label),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Color(0xFF005C45))
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}


class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModernBottomNavigationBar(
      currentIndex: 2,
      onHomeTap: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.home,
          (route) => false,
        );
      },
      onReportTap: () => Navigator.pushNamed(context, RouteNames.complaintForm),
      onProfileTap: () {},
    );
  }
}

class _FloatingReportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () => Navigator.pushNamed(context, RouteNames.complaintForm),
      backgroundColor: const Color(0xFF005C45),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
