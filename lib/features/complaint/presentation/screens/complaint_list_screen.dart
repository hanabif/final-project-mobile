import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
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
    return BlocProvider(
      create: (context) => sl<ComplaintListCubit>()..fetchComplaints(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(RouteNames.profile);
              }
            },
          ),
          title: const Text(
            'My Reports',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Resolved'),
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
                  _buildComplaintList(state.complaints),
                  _buildComplaintList(state.complaints
                      .where((c) => c.status.toLowerCase() != 'resolved')
                      .toList()),
                  _buildComplaintList(state.complaints
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

  Widget _buildComplaintList(List complaints) {
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
            const Text(
              'No more issues to show.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the '+' to file a new report.",
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
                  Navigator.pushNamed(
                    context,
                    RouteNames.complaintStatus,
                    arguments: complaint.id.toString(),
                  );
                },
              ))
          .toList(),
    );
  }
}
