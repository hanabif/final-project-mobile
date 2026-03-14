import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../widgets/settings_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsCubit>()..loadSettings(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF005C45), // Deep green from image
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsError) {
              return Center(child: Text(state.message));
            } else if (state is SettingsLoaded) {
              final settings = state.settings;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildSectionContainer(
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(Icons.person, size: 50, color: Colors.grey),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Abebe Bikila',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+251 91 123 4567',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                Text(
                                  'abebe.b@example.com',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note, color: Colors.grey.shade400),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // My Complaints
                    const Text(
                      'My Complaints',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSectionContainer(
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(child: _StatWidget(title: 'Total', value: '15')),
                              VerticalDivider(height: 40),
                              Expanded(child: _StatWidget(title: 'Resolved', value: '8')),
                            ],
                          ),
                          const Divider(height: 32),
                          const Row(
                            children: [
                              Expanded(child: _StatWidget(title: 'In Progress', value: '5')),
                              VerticalDivider(height: 40),
                              Expanded(child: _StatWidget(title: 'Pending', value: '2')),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, RouteNames.complaintList),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005C45),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSectionContainer(
                      child: Column(
                        children: [
                          SettingsItem(
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.phone_android_outlined,
                            title: 'Change Phone Number',
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.email_outlined,
                            title: 'Email Verification',
                            value: 'Verified',
                            trailing: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.visibility_off_outlined,
                            title: 'Anonymous Mode',
                            trailing: Switch(
                              value: settings.isAnonymousMode,
                              onChanged: (val) => context.read<SettingsCubit>().toggleAnonymousMode(val),
                              activeColor: const Color(0xFFFCD703),
                            ),
                            onTap: () {},
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'When enabled, your complaints will be submitted anonymously.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Preferences
                    const Text(
                      'Preferences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSectionContainer(
                      child: Column(
                        children: [
                          SettingsItem(
                            icon: Icons.language,
                            title: 'Language',
                            value: settings.language,
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notification Settings',
                            trailing: Switch(
                              value: settings.isNotificationsEnabled,
                              onChanged: (val) => context.read<SettingsCubit>().toggleNotifications(val),
                              activeColor: const Color(0xFFFCD703),
                            ),
                            onTap: () {},
                          ),
                          SettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Theme Mode',
                            trailing: _ThemeSwitch(
                              current: settings.themeMode,
                              onChanged: (val) => context.read<SettingsCubit>().setThemeMode(val),
                            ),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005C45),
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
        ),
        bottomNavigationBar: _BottomNavBar(),
        floatingActionButton: _FloatingReportButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String title;
  final String value;

  const _StatWidget({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFCD703),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _ThemeSwitch({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption('Light'),
          _buildOption('Dark'),
        ],
      ),
    );
  }

  Widget _buildOption(String value) {
    bool isSelected = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCD703) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Profile selected
      onTap: (index) {
        if (index == 0) Navigator.popUntil(context, ModalRoute.withName(RouteNames.home));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.edit_document, color: Colors.transparent), label: 'Report'),
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
