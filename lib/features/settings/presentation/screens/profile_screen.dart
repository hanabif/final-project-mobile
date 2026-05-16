import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../../../complaint/presentation/cubits/profile/profile_cubit.dart';
import '../widgets/settings_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProfileCubit>()..loadProfileData(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Profile',
          showBackButton: true,
          showThemeToggle: true,
          showNotification: true,
          backgroundColor: const Color(0xFF005C45),
        ),
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            } else if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Text(
                          'My Complaints',
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
                                  child: const Text('View All Complaints'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account Settings
                        const Text(
                          'Account Settings',
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
                                title: 'Edit Profile',
                                onTap: () => _showEditProfileDialog(
                                  context,
                                  user.name,
                                  context.read<ProfileCubit>(),
                                ),
                              ),
                              SettingsItem(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
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
                        const Text(
                          'Preferences',
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
                                icon: Icons.language,
                                title: 'Language',
                                value: settings.language,
                                onTap: () {},
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
                            child: const Text('Logout'),
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

          return AlertDialog(
            title: const Text('Edit Profile'),
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
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
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
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
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

          return AlertDialog(
            title: const Text('Change Password'),
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
                          decoration: const InputDecoration(
                            labelText: 'Current Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: !isLoading,
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: !isLoading,
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != newPasswordController.text) {
                              return 'Passwords do not match';
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
                child: const Text('Cancel'),
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
                    : const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}


class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_document, color: Colors.transparent),
          label: 'Report',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class _FloatingReportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, RouteNames.complaintForm),
      backgroundColor: const Color(0xFF005C45),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
