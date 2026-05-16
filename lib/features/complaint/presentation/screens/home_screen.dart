import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/organization_logo_mapper.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_bottom_navigation_bar.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../../notification/presentation/cubit/notification_cubit.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/organization_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<NotificationCubit>().fetchNotifications();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Home - Already here
    } else if (index == 1) {
      // Navigate to Report (Complaint Form)
      Navigator.pushNamed(context, RouteNames.complaintForm);
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.pushNamed(context, RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: null,
        showBackButton: false,
        showThemeToggle: true,
        showNotification: true,
        backgroundColor: const Color(0xFF005C45),
        logoAssetPath: 'assets/icons/logo (2).png',
        logoWidth: 110,
        logoHeight: 32,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          } else if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeCubit>().loadHomeData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.complaintStatistics,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: l10n.totalComplaints,
                            number: state.totalComplaints.toString(),
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.complaintList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: l10n.resolvedCases,
                            number: state.resolvedComplaints.toString(),
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.complaintList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: l10n.pendingCases,
                            number: state.pendingComplaints.toString(),
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.complaintList,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.complaintCategories,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9, // Adjusted height
                          ),
                      itemCount: state.organizations.length,
                      itemBuilder: (context, index) {
                        final org = state.organizations[index];
                        final name = org['name'] ?? 'Unknown';
                        final logo = OrganizationLogoMapper.getLogoPath(name);

                        return OrganizationCard(
                          name: name,
                          logo: logo,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.complaintForm,
                              arguments: org['id'],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.complaintForm);
        },
        backgroundColor: const Color(0xFF005C45),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ModernBottomNavigationBar(
        currentIndex: _selectedIndex,
        onHomeTap: () {},
        onReportTap: () => Navigator.pushNamed(context, RouteNames.complaintForm),
        onProfileTap: () => Navigator.pushNamed(context, RouteNames.profile),
      ),
    );
  }
}
