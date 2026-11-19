import 'dart:ui';

import 'package:flutter/material.dart';

// ==========================================
// TANOVA COMPANY - INCOMING BOOKINGS
// ==========================================

class CompanyBookings extends StatefulWidget {
  const CompanyBookings({super.key});

  @override
  State<CompanyBookings> createState() => _CompanyBookingsState();
}

class _CompanyBookingsState extends State<CompanyBookings> {
  int selectedTab = 0;
  bool isOnline = false;

  final List<String> tabs = ['New', 'Accepted', 'Completed'];

  // ==========================================
  // ONLINE / OFFLINE CONTROL
  // ==========================================

  Widget buildOnlineCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isOnline
                        ? Icons.check_circle_rounded
                        : Icons.power_settings_new_rounded,
                    color: isOnline ? const Color(0xFF00E5A0) : Colors.white,
                    size: 32,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Company Online' : 'Company Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isOnline
                              ? 'Ready to receive booking requests'
                              : 'Not accepting new requests',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isOnline = !isOnline;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOnline
                              ? 'Company is now online'
                              : 'Company is now offline',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    isOnline
                        ? Icons.power_settings_new_rounded
                        : Icons.wifi_rounded,
                  ),
                  label: Text(
                    isOnline ? 'Go Offline' : 'Go Online',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnline
                        ? const Color(0xFFE53935)
                        : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOOKING FILTER TABS
  // ==========================================

  Widget buildTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF002B60).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1677FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // BOOKING CARD - FIREBASE READY
  // ==========================================

  Widget buildBookingCard({
    required String bookingId,
    required String pickup,
    required String destination,
    required String passenger,
    required String time,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF10B981)),
                        Container(
                          width: 2,
                          height: 24,
                          color: Colors.grey.shade300,
                        ),
                        const Icon(Icons.location_on, color: Colors.redAccent),
                      ],
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B4D),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            destination,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF35445A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 18,
                      color: Color(0xFF172B4D),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        passenger,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF35445A),
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B9BB1),
                      ),
                    ),
                  ],
                ),

                if (status == 'new') ...[
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Firebase accept booking
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Connect Firebase to accept bookings',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Firebase decline booking
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Connect Firebase to decline bookings',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE5E5),
                            foregroundColor: const Color(0xFFE53935),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY BOOKINGS STATE
  // ==========================================

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: Colors.white.withValues(alpha: 0.85),
            size: 55,
          ),

          const SizedBox(height: 14),

          Text(
            'No ${tabs[selectedTab].toLowerCase()} bookings',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Bookings will appear here once connected.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN BOOKINGS PAGE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),

        // PAGE TITLE
        const Text(
          'Receive requests.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        // GO ONLINE / OFFLINE CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: buildOnlineCard(),
        ),

        const SizedBox(height: 20),

        // BOOKING TABS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: buildTabs(),
        ),

        const SizedBox(height: 15),

        // BOOKING LIST - FIREBASE LATER
        Expanded(child: buildEmptyState()),
      ],
    );
  }
}
