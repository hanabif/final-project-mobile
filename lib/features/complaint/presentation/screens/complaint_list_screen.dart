import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/complaint_list_cubit.dart';
import '../cubits/complaint_list_state.dart';
import '../widgets/complaint_card.dart';

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _selectedIndex = 0;

  static const _tabs = [
    _TabItem(label: 'All',        icon: Icons.grid_view_rounded),
    _TabItem(label: 'Submitted',  icon: Icons.upload_file_rounded),
    _TabItem(label: 'In Progress',icon: Icons.autorenew_rounded),
    _TabItem(label: 'Resolved',   icon: Icons.check_circle_outline_rounded),
    _TabItem(label: 'Rejected',   icon: Icons.cancel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) return;
        setState(() => _selectedIndex = _tabController.index);
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  // Refresh data when app comes to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshComplaints();
    }
  }

  void _refreshComplaints() {
    if (mounted) {
      print('🔄 Refreshing complaint list on screen resume');
      // Slight delay to ensure backend has processed
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          sl<ComplaintListCubit>().fetchComplaints(forceRefresh: true);
        }
      });
    }
  }

  // ── status helpers ────────────────────────────────────────────────────────

  List _filter(List complaints, int tabIndex) {
    if (tabIndex == 0) return complaints;
    final matchers = [
      null, // All — handled above
      (String s) => s == 'submitted',
      (String s) => s == 'in progress' || s == 'in_progress'
                 || s == 'manual review' || s == 'manual_review'
                 || s == 'under review',
      (String s) => s == 'resolved',
      (String s) => s == 'rejected',
    ];
    return complaints
        .where((c) => matchers[tabIndex]!(c.status.toLowerCase()))
        .toList();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context)!;
    final theme   = Theme.of(context);
    final isDark  = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<ComplaintListCubit>()..fetchComplaints(forceRefresh: true),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
        appBar: CustomAppBar(
          title: l10n.myReports,
          showBackButton: true,
          showThemeToggle: true,
          showNotification: true,
          onBackPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(RouteNames.profile);
            }
          },
        ),

        // ── Floating tab row + content ──────────────────────────────────────
        body: Column(
          children: [
            _FloatingTabBar(
              tabs: _tabs,
              controller: _tabController,
              selectedIndex: _selectedIndex,
              isDark: isDark,
            ),

            // ── Tab content ────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ComplaintListCubit, ComplaintListState>(
                builder: (context, state) {
                  if (state is ComplaintListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF26A3D),
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is ComplaintListError) {
                    return _ErrorView(message: state.message);
                  }
                  if (state is ComplaintListLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: List.generate(
                        _tabs.length,
                        (i) => _ComplaintListView(
                          complaints: _filter(state.complaints, i),
                          l10n: l10n,
                          isDark: isDark,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),

        floatingActionButton: _AddFAB(
          onPressed: () =>
              Navigator.pushNamed(context, RouteNames.complaintForm),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Floating Tab Bar
// ════════════════════════════════════════════════════════════════════════════

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({
    required this.tabs,
    required this.controller,
    required this.selectedIndex,
    required this.isDark,
  });

  final List<_TabItem> tabs;
  final TabController controller;
  final int selectedIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : const Color(0xFFF26A3D).withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          tabs: List.generate(tabs.length, (i) {
            final selected = selectedIndex == i;
            return _AnimatedTab(
              item: tabs[i],
              selected: selected,
              isDark: isDark,
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedTab extends StatelessWidget {
  const _AnimatedTab({
    required this.item,
    required this.selected,
    required this.isDark,
  });

  final _TabItem item;
  final bool selected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFFF26A3D), Color(0xFFE8522A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFFF26A3D).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 15,
            color: selected
                ? Colors.white
                : (isDark ? Colors.white54 : Colors.black45),
          ),
          const SizedBox(width: 5),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white60 : Colors.black54),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Complaint List View
// ════════════════════════════════════════════════════════════════════════════

class _ComplaintListView extends StatelessWidget {
  const _ComplaintListView({
    required this.complaints,
    required this.l10n,
    required this.isDark,
  });

  final List complaints;
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return _EmptyState(l10n: l10n, isDark: isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: complaints.length,
      itemBuilder: (context, i) {
        final complaint = complaints[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ComplaintCard(
            complaint: complaint,
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.complaintStatus,
              arguments: complaint,
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.isDark});

  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF5F6FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noMoreIssuesToShow,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tapPlusToFileNewReport,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Error View
// ════════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FAB
// ════════════════════════════════════════════════════════════════════════════

class _AddFAB extends StatelessWidget {
  const _AddFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF005C45),
      foregroundColor: Colors.white,
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}