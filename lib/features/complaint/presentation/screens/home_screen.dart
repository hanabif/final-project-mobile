import 'package:complaint_resolution_app/core/utils/qr_complaint_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/organization_logo_mapper.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_bottom_navigation_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notification/presentation/cubit/notification_cubit.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../widgets/qr_scanner_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<NotificationCubit>().fetchNotifications();
  }


  void _openQRScanner(BuildContext context) async {
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
          'description': qrData.description,
          'latitude': qrData.latitude,
          'longitude': qrData.longitude,
          'locationLabel': qrData.locationLabel,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: null,
        showBackButton: false,
        showThemeToggle: true,
        showNotification: true,
        backgroundColor: const Color(0xFF005C45),
        logoAssetPath: 'assets/icons/logo (2).png',
        logoWidth: 110,
        logoHeight: 48,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF005C45)),
            );
          }
          if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          if (state is HomeLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF005C45),
              onRefresh: () async =>
                  context.read<HomeCubit>().loadHomeData(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Hero Banner ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _HeroBanner(isDark: isDark, l10n: l10n),
                  ),

                  // ── Stats row ──────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: l10n.complaintStatistics,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModernStatCard(
                              label: l10n.totalComplaints,
                              value: state.totalComplaints.toString(),
                              icon: Icons.bar_chart_rounded,
                              color: const Color(0xFF3B82F6),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModernStatCard(
                              label: l10n.resolvedCases,
                              value: state.resolvedComplaints.toString(),
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF22C55E),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ModernStatCard(
                              label: l10n.pendingCases,
                              value: state.pendingComplaints.toString(),
                              icon: Icons.hourglass_top_rounded,
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Categories ─────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: l10n.complaintCategories,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final org  = state.organizations[index];
                          final name = org['name'] ?? 'Unknown';
                          final logo = OrganizationLogoMapper.getLogoPath(name);
                          return _ModernOrgCard(
                            name: name,
                            logo: logo,
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.complaintForm,
                              arguments: org['id'],
                            ),
                          );
                        },
                        childCount: state.organizations.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ModernBottomNavigationBar(
          currentIndex: 0,
          onHomeTap: () {},
          onReportTap: () =>
              Navigator.pushNamed(context, RouteNames.complaintForm),
          onProfileTap: () =>
              Navigator.pushNamed(context, RouteNames.profile),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQRScanner(context),
        backgroundColor: const Color(0xFF005C45),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Hero Banner
// ════════════════════════════════════════════════════════════════════════════

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.isDark, required this.l10n});
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF005C45), Color(0xFF00855F), Color(0xFF00A86B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005C45).withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Megaphone / civic illustration
          Positioned(
            right: 16,
            bottom: 0,
            top: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  const Icon(
                    Icons.campaign_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // Text content
          Positioned(
            left: 22,
            top: 0,
            bottom: 0,
            right: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourVoiceMatters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.reportIssuesInYourCommunity,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12,
                    height: 1.4,
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

// ════════════════════════════════════════════════════════════════════════════
// Section header
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF005C45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Modern Stat Card
// ════════════════════════════════════════════════════════════════════════════

class _ModernStatCard extends StatelessWidget {
  const _ModernStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.13),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Modern Org Card
// ════════════════════════════════════════════════════════════════════════════

class _ModernOrgCard extends StatelessWidget {
  const _ModernOrgCard({
    required this.name,
    required this.logo,
    required this.isDark,
    required this.onTap,
  });

  final String name;
  final String logo;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFF0FAF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.business_rounded,
                  size: 28,
                  color: const Color(0xFF005C45),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF005C45).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Report →',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF005C45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}