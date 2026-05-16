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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => sl<ComplaintListCubit>()..fetchComplaints(),
      child: Scaffold(
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
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: l10n.all),
              Tab(text: l10n.active),
              Tab(text: l10n.resolved),
            ],
          ),
        ),
        body: BlocBuilder<ComplaintListCubit, ComplaintListState>(
          builder: (context, state) {
            if (state is ComplaintListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ComplaintListError) {
              return Center(child: Text(state.message));
            } else if (state is ComplaintListLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildComplaintList(context, l10n, state.complaints),
                  _buildComplaintList(context, l10n, state.complaints
                      .where((c) => c.status.toLowerCase() != 'resolved')
                      .toList()),
                  _buildComplaintList(context, l10n, state.complaints
                      .where((c) => c.status.toLowerCase() == 'resolved')
                      .toList()),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF005C45), // Matching image FAB color
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, RouteNames.complaintForm);
          },
          child: const Icon(Icons.add, size: 36),
        ),
      ),
    );
  }

  Widget _buildComplaintList(
    BuildContext context,
    AppLocalizations l10n,
    List complaints,
  ) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMoreIssuesToShow,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapPlusToFileNewReport,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: complaints
          .map((complaint) => ComplaintCard(
                complaint: complaint,
                onTap: () {
                  // Pass the full Complaint object — the detail screen
                  // uses it immediately with no extra API call.
                  Navigator.pushNamed(
                    context,
                    RouteNames.complaintStatus,
                    arguments: complaint,
                  );
                },
              ))
          .toList(),
    );
  }

}
