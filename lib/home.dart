import 'dart:ui';

import 'package:flutter/material.dart';

import 'driver.dart';
import 'onlinebooking.dart';

class CompanyNotification {
  final String title;
  final String message;
  bool unread;

  CompanyNotification({
    required this.title,
    required this.message,
    this.unread = true,
  });
}

// ==========================================
// TANOVA COMPANY HOME SCREEN
// ==========================================

class CompanyHome extends StatefulWidget {
  final String companyName;
  final ValueChanged<BuildContext> onLogout;

  const CompanyHome({
    super.key,
    required this.companyName,
    required this.onLogout,
  });

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  int selectedIndex = 0;
  final List<CompanyNotification> notifications = [];

  // ==========================================
  // DASHBOARD DATA - FIREBASE READY
  // ==========================================

  int? newRequests;
  int? activeTrips;
  int? completedToday;
  int? activeDrivers;

  // Firebase will populate these values later.
  // Null means the data has not been loaded.

  // ==========================================
  // TOP APP BAR
  // ==========================================

  Widget buildTopAppBar() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Open menu',
          onPressed: () => showMenuPanel(context),
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        ),
        const Expanded(
          child: Text(
            'PARTNERSHIP PLATFORM',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => showNotificationsPanel(context),
          icon: Icon(
            notifications.any((notification) => notification.unread)
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
            color: const Color(0xFFB4DEFF),
            size: 28,
          ),
        ),
      ],
    );
  }

  Future<void> showMenuPanel(BuildContext pageContext) async {
    const destinations = [
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Bookings', icon: Icons.receipt_long_rounded),
      (label: 'Drivers', icon: Icons.people_outline_rounded),
      (label: 'Profile', icon: Icons.business_outlined),
    ];

    await showModalBottomSheet<void>(
      context: pageContext,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                widget.companyName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Company account'),
              leading: const CircleAvatar(child: Icon(Icons.business)),
            ),
            const Divider(height: 1),
            for (var index = 0; index < destinations.length; index++)
              ListTile(
                leading: Icon(destinations[index].icon),
                title: Text(destinations[index].label),
                selected: selectedIndex == index,
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => selectedIndex = index);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pop(sheetContext);
                widget.onLogout(pageContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showNotificationsPanel(BuildContext pageContext) async {
    await showModalBottomSheet<void>(
      context: pageContext,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (notifications.any(
                      (notification) => notification.unread,
                    ))
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (final notification in notifications) {
                              notification.unread = false;
                            }
                          });
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Mark all read'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 42,
                              color: Color(0xFF8290A4),
                            ),
                            SizedBox(height: 10),
                            Text('No notifications yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            leading: Icon(
                              notification.unread
                                  ? Icons.circle
                                  : Icons.notifications_none_rounded,
                              size: notification.unread ? 12 : 24,
                              color: const Color(0xFF1677FF),
                            ),
                            title: Text(notification.title),
                            subtitle: Text(notification.message),
                            onTap: () {
                              setState(() => notification.unread = false);
                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (mounted) setState(() {});
  }

  // ==========================================
  // MESSAGE FUNCTION
  // ==========================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================
  // GLASS DASHBOARD STATISTICS CARD
  // ==========================================

  Widget buildStatCard({
    required IconData icon,
    required int? number,
    required String title,
    required Color color,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.70),
              ],
            ),

            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 15,
              ),
            ],
          ),

          child: Row(
            children: [
              // CARD ICON
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),

              const SizedBox(width: 10),

              // CARD DETAILS
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number?.toString() ?? '—',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10233F),
                      ),
                    ),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF35445A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RECENT BOOKINGS PANEL
  // ==========================================

  Widget buildRecentBookings() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),

            borderRadius: BorderRadius.circular(22),

            border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
          ),

          child: Column(
            children: [
              // PANEL HEADING
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Bookings',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10233F),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const Divider(),

              // EMPTY STATE UNTIL FIREBASE
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 38,
                      color: Color(0xFF9BA9BC),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'No bookings to display',
                      style: TextStyle(fontSize: 14, color: Color(0xFF68778E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HOME DASHBOARD
  // ==========================================

  Widget buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 110),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COMPANY GREETING
          Text(
            'Bula, ${widget.companyName}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Manage your bookings and drivers',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 22),

          // ==================================
          // DASHBOARD STATISTICS
          // ==================================
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.65,

            children: [
              // NEW REQUESTS
              buildStatCard(
                icon: Icons.local_taxi_rounded,
                number: newRequests,
                title: 'New Requests',
                color: const Color(0xFF3A9BFF),
                iconColor: const Color(0xFF1776F5),
              ),

              // ACTIVE TRIPS
              buildStatCard(
                icon: Icons.check_rounded,
                number: activeTrips,
                title: 'Active Trips',
                color: const Color(0xFFB7F0E2),
                iconColor: const Color(0xFF10B981),
              ),

              // COMPLETED TODAY
              buildStatCard(
                icon: Icons.access_time_filled_rounded,
                number: completedToday,
                title: 'Completed Today',
                color: const Color(0xFFFFE5C9),
                iconColor: const Color(0xFFFF861C),
              ),

              // ACTIVE DRIVERS
              buildStatCard(
                icon: Icons.people_rounded,
                number: activeDrivers,
                title: 'Active Drivers',
                color: const Color(0xFFE5D7FF),
                iconColor: const Color(0xFF9348ED),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // RECENT BOOKINGS
          buildRecentBookings(),
        ],
      ),
    );
  }

  // ==========================================
  // TEMPORARY OTHER PAGES
  // ==========================================

  Widget buildPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 65, color: Colors.white),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfilePage() {
    final companyName = widget.companyName;
    final initials = companyName.isEmpty ? '?' : companyName[0].toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 28),
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF1677FF),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            companyName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Company account',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 28),
          buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account details',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company name',
                  style: TextStyle(color: Color(0xFF68778E), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  style: const TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Account type',
                  style: TextStyle(color: Color(0xFF68778E), fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Company',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => widget.onLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.75)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // APPLE-STYLE GLASS BOTTOM NAVIGATION
  // ==========================================

  Widget buildGlassNavBar() {
    final icons = [
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.people_outline_rounded,
      Icons.menu_rounded,
    ];

    final labels = ['Home', 'Bookings', 'Drivers', 'Profile'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

        child: Container(
          height: 72,

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.80),

            borderRadius: BorderRadius.circular(25),

            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
              ),
            ],
          ),

          child: Row(
            children: List.generate(icons.length, (index) {
              final isSelected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 24,
                        color: isSelected
                            ? const Color(0xFF1677FF)
                            : const Color(0xFF8290A4),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,

                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,

                          color: isSelected
                              ? const Color(0xFF1677FF)
                              : const Color(0xFF8290A4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MAIN SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildDashboard(),

      const CompanyBookings(),

      const CompanyDrivers(),

      buildProfilePage(),
    ];

    return Scaffold(
      extendBody: true,

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==================================
          // COMPANY BACKGROUND IMAGE
          // ==================================

          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Image.asset(
                'lib/asset/image/background_company.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(color: Color(0xFF063B78));
                },
              ),
            ),
          ),

          // ==================================
          // PAGE CONTENT
          // ==================================
          SafeArea(
            child: Column(
              children: [
                // TOP APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: buildTopAppBar(),
                ),

                // MAIN CONTENT
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          ),
        ],
      ),

      // ==================================
      // GLASS BOTTOM NAVIGATION
      // ==================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: buildGlassNavBar(),
        ),
      ),
    );
  }

  buildGlassCard({required Column child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
