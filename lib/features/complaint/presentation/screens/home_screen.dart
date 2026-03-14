import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/route_names.dart';
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
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to Report (Complaint Form)
      Navigator.pushNamed(context, RouteNames.complaintForm);
    } else if (index == 2) {
      // Navigate to Profile
      // Placeholder for now
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Screen - Coming Soon')),
      );
    } else {
      // Home
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo (1).png',
          height: 40,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // Placeholder for profile navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Screen - Coming Soon')),
              );
            },
          )
        ],
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
                    const Text(
                      'Complaint Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: StatCard(title: 'Total Complaints', number: state.totalComplaints.toString())),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Resolved Cases', number: state.resolvedComplaints.toString())),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Pending Cases', number: state.pendingComplaints.toString())),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Complaint Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: state.organizations.length,
                      itemBuilder: (context, index) {
                        final org = state.organizations[index];
                        return OrganizationCard(
                          name: org['name']!,
                          logo: org['logo']!,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.complaintForm,
                              arguments: org['name'],
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
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Empty item visually to make space for the FAB
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document, color: Colors.transparent),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
