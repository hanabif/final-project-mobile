import 'package:complaint_resolution_app/l10n/app_localizations_am.dart';
import 'package:complaint_resolution_app/l10n/app_localizations_om.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_bottom_navigation_bar.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../../core/widgets/connection_lost_state_view.dart';
import '../../../../core/utils/qr_complaint_parser.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../complaint/presentation/cubits/home/home_cubit.dart';
import '../../../complaint/presentation/widgets/qr_scanner_modal.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../../../complaint/presentation/cubits/profile/profile_cubit.dart';
import '../widgets/settings_item.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve app strings according to settings (supports Oromo via generated class)
    final settingsState = context.select<SettingsCubit, SettingsState>((c) => c.state);
    AppLocalizations l10n;
    if (settingsState is SettingsLoaded) {
      final lang = settingsState.settings.language.trim().toLowerCase();
      if (lang.contains('om') || lang.contains('orom') || lang.contains('afaan')) {
        l10n = AppLocalizationsOm();
      } else if (lang.contains('am') || lang.contains('amh') || lang.contains('amharic')) {
        l10n = AppLocalizationsAm();
      } else {
        l10n = AppLocalizations.of(context)!;
      }
    } else {
      l10n = AppLocalizations.of(context)!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: sl<ProfileCubit>()..loadProfileData(),
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
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
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF005C45)),
                    );
                  }
                  if (profileState is ProfileOffline) {
                    return _OfflineProfileView(
                      message: profileState.message,
                      onRetry: () => context.read<ProfileCubit>().loadProfileData(forceRefresh: true),
                    );
                  }
                  if (profileState is ProfileError) {
                    return _OfflineProfileView(
                      message: profileState.message,
                      onRetry: () => context.read<ProfileCubit>().loadProfileData(forceRefresh: true),
                    );
                  }
                  if (settingsState is SettingsError) {
                    return Center(child: Text(settingsState.message));
                  }
                  if (profileState is ProfileLoaded &&
                      settingsState is SettingsLoaded) {
                    final settings = settingsState.settings;
                    final user     = profileState.user;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar + name card ─────────────────────────
                          _ProfileHeaderCard(user: user, isDark: isDark),
                          const SizedBox(height: 20),

                            // ── Call Center ────────────────────────────────
                            _SectionLabel(label: l10n.callCenter, isDark: isDark),
                            const SizedBox(height: 10),
                            _ActionTile(
                            icon: Icons.phone_in_talk_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            label: l10n.callCenterContacts,
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14),
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(
                              context, RouteNames.callCenter),
                            ),
                            const SizedBox(height: 20),

                          // ── Account Settings ───────────────────────────
                          _SectionLabel(
                              label: l10n.accountSettings, isDark: isDark),
                          const SizedBox(height: 10),
                          _SettingsGroup(isDark: isDark, children: [
                            _ActionTile(
                              icon: Icons.edit_rounded,
                              iconColor: const Color(0xFF005C45),
                              label: l10n.editProfile,
                              isDark: isDark,
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () => _showEditProfileDialog(
                                context,
                                user.name,
                                context.read<ProfileCubit>(),
                              ),
                            ),
                            _Divider(isDark: isDark),
                            _ActionTile(
                              icon: Icons.lock_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              label: l10n.changePassword,
                              isDark: isDark,
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () => _showChangePasswordDialog(
                                context,
                                context.read<ProfileCubit>(),
                              ),
                            ),
                            _Divider(isDark: isDark),
                            _ActionTile(
                              icon: Icons.info_outline_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              label: l10n.about,
                              isDark: isDark,
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () => Navigator.pushNamed(
                                context,
                                RouteNames.about,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 20),

                          // ── Language ───────────────────────────────────
                          _SectionLabel(
                              label: l10n.preferences, isDark: isDark),
                          const SizedBox(height: 10),
                          _SettingsGroup(isDark: isDark, children: [
                            _LanguageExpansion(
                              settings: settings,
                              l10n: l10n,
                              isDark: isDark,
                            ),
                            _Divider(isDark: isDark),
                            const SizedBox(height: 10),
                            _NotificationToggleTile(
                              isEnabled: settings.isNotificationsEnabled,
                              isDark: isDark,
                              onChanged: (value) {
                                context.read<SettingsCubit>().toggleNotifications(value);
                              },
                            ),
                            const SizedBox(height: 20),
                          ]),
                          const SizedBox(height: 28),

                          // ── Logout button ──────────────────────────────
                          _LogoutButton(l10n: l10n, isDark: isDark),
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _BottomNavBar(),
        ),
        floatingActionButton: _FloatingQRButton(),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showEditProfileDialog(
      BuildContext context, String currentName, ProfileCubit profileCubit) {
    final nameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          BlocBuilder<ProfileCubit, ProfileState>(
        bloc: profileCubit,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final isLoading = state is ProfileLoading;
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l10n.editProfile,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            content: isLoading
                ? const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()))
                : Form(
                    key: formKey,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.nameIsRequired : null,
                    ),
                  ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005C45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
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
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.update),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, ProfileCubit profileCubit) {
    final oldCtrl     = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          StatefulBuilder(
            builder: (stateContext, setDialogState) =>
              BlocBuilder<ProfileCubit, ProfileState>(
              bloc: profileCubit,
              builder: (context, state) {
                final l10n      = AppLocalizations.of(context)!;
                final isDark    = Theme.of(context).brightness == Brightness.dark;
                final isLoading = state is ProfileLoading;
                return AlertDialog(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(l10n.changePassword,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  content: isLoading
                      ? const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()))
                      : SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _DialogField(
                                    ctrl: oldCtrl,
                                    label: l10n.currentPassword,
                                    obscure: true,
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? l10n.currentPasswordIsRequired
                                        : null),
                                const SizedBox(height: 12),
                                _DialogField(
                                  ctrl: newCtrl,
                                  label: l10n.newPassword,
                                  obscure: true,
                                  validator: (v) => PasswordValidator.validatePassword(v ?? ''),
                                  onChanged: (_) => setDialogState(() {}),
                                ),
                                PasswordStrengthIndicator(
                                  password: newCtrl.text,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 12),
                                _DialogField(
                                    ctrl: confirmCtrl,
                                    label: l10n.confirmPassword,
                                    obscure: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return l10n.pleaseConfirmPassword;
                                      if (v != newCtrl.text)
                                        return l10n.passwordsDoNotMatch;
                                      return null;
                                    }),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(dialogContext),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005C45),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                // Additional check for strong password
                                if (!PasswordValidator.isStrongPassword(newCtrl.text.trim())) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.weakPassword),
                                    ),
                                  );
                                  return;
                                }
                                
                                profileCubit
                                    .changePassword(oldCtrl.text, newCtrl.text)
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
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.save),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  String _normalizeLanguage(String language) {
    final lower = language.toLowerCase();
    if (lower.contains('am')) return 'Amharic';
    if (lower.contains('om')) return 'Oromic';
    return 'English';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════════════════════

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005C45), Color(0xFF00855F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005C45).withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.person_rounded,
                size: 38, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children, required this.isDark});
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.20)
                : Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            if (trailing != null)
              IconTheme(
                data: IconThemeData(
                  color: isDark ? Colors.white38 : Colors.black26,
                  size: 14,
                ),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 52,
        endIndent: 16,
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
      );
}

class _LanguageExpansion extends StatelessWidget {
  const _LanguageExpansion({
    required this.settings,
    required this.l10n,
    required this.isDark,
  });
  final dynamic settings;
  final AppLocalizations l10n;
  final bool isDark;

  String _normalize(String lang) {
    final value = lang.trim().toLowerCase();
    if (value.contains('am') || value.contains('amh') || value.contains('amharic')) {
      return 'am';
    }
    if (value.contains('om') || value.contains('orom') || value.contains('afaan')) {
      return 'om';
    }
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language_rounded,
              size: 18, color: Color(0xFF3B82F6)),
        ),
        title: Text(
          l10n.language,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          settings.language,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        children: [
          _LangOption(
            label: l10n.english,
            selected: _normalize(settings.language) == 'en',
            isDark: isDark,
            onTap: () =>
                context.read<SettingsCubit>().setLanguage(l10n.english),
          ),
          const SizedBox(height: 6),
          _LangOption(
            label: l10n.amharic,
            selected: _normalize(settings.language) == 'am',
            isDark: isDark,
            onTap: () =>
                context.read<SettingsCubit>().setLanguage(l10n.amharic),
          ),
          const SizedBox(height: 6),
          _LangOption(
            label: l10n.oromic,
            selected: _normalize(settings.language) == 'om',
            isDark: isDark,
            onTap: () =>
                context.read<SettingsCubit>().setLanguage(l10n.oromic),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.isEnabled,
    required this.isDark,
    required this.onChanged,
  });

  final bool isEnabled;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              size: 18,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.enableNotifications,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.notificationsDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF005C45).withOpacity(0.10)
              : (isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: const Color(0xFF005C45).withOpacity(0.35),
                  width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF005C45)
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const Spacer(),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              size: 18,
              color: selected
                  ? const Color(0xFF005C45)
                  : (isDark ? Colors.white30 : Colors.black26),
            ),
          ],
        ),
      ),
    );
  }
}

/// Direct logout button — no confirmation dialog.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await sl<LogoutUseCase>()();
        sl<ProfileCubit>().clearCache();
        sl<HomeCubit>().clearCache();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, RouteNames.login, (route) => false);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.25),
              width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 10),
            Text(
              l10n.logout,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.validator,
    this.onChanged,
  });
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModernBottomNavigationBar(
      currentIndex: 3,
      onHomeTap: () => Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.home, (route) => false),
      onReportTap: () =>
          Navigator.pushNamed(context, RouteNames.complaintForm),
      onComplaintsTap: () =>
          Navigator.pushNamed(context, RouteNames.complaintList),
      onProfileTap: () {},
    );
  }
}

class _FloatingQRButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () async {
        final navigator = Navigator.of(context);
        final qrData = await showDialog<QRComplaintData>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const QRScannerModal(),
        );

        if (qrData != null) {
          navigator.pushNamed(
            RouteNames.complaintForm,
            arguments: {
              'organizationId': qrData.organizationId,
              'title': qrData.title,
            },
          );
        }
      },
      backgroundColor: const Color(0xFF005C45),
      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
    );
  }
}

class _OfflineProfileView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OfflineProfileView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      color: const Color(0xFF005C45),
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        children: [
          ConnectionLostStateView(
            title: 'Connection Lost!',
            subtitle: message,
            buttonLabel: l10n.retry,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}