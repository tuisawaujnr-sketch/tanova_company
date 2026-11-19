import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================
// TANOVA COMPANY - DRIVER MANAGEMENT
// ============================================

class CompanyDrivers extends StatefulWidget {
  const CompanyDrivers({super.key});

  @override
  State<CompanyDrivers> createState() => _CompanyDriversState();
}

// ============================================
// DRIVER MODEL
// ============================================

class CompanyDriver {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;

  String status;
  String? bookingId;
  String? pickup;
  String? destination;

  CompanyDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    this.status = 'Offline',
    this.bookingId,
    this.pickup,
    this.destination,
  });
}

// ============================================
// DRIVER MANAGEMENT STATE
// ============================================

class _CompanyDriversState extends State<CompanyDrivers> {
  final List<CompanyDriver> drivers = [];

  int nextDriverId = 1;

  String selectedFilter = 'All';

  final Color navy = const Color(0xFF10233F);
  final Color blue = const Color(0xFF1677FF);
  final Color green = const Color(0xFF10B981);
  final Color orange = const Color(0xFFFF941A);

  int get totalDrivers => drivers.length;

  int get availableDrivers =>
      drivers.where((d) => d.status == 'Available').length;

  int get busyDrivers => drivers.where((d) => d.status == 'On Trip').length;

  int get offlineDrivers => drivers.where((d) => d.status == 'Offline').length;

  List<CompanyDriver> get filteredDrivers {
    if (selectedFilter == 'All') {
      return drivers;
    }

    return drivers.where((driver) => driver.status == selectedFilter).toList();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================
  // GLASS CARD
  // ============================================

  Widget buildGlassCard({
    required Widget child,
    bool light = true,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================
  // STATUS COLOURS
  // ============================================

  Color statusColor(String status) {
    switch (status) {
      case 'Available':
        return green;
      case 'On Trip':
        return orange;
      default:
        return const Color(0xFF8895A7);
    }
  }

  // ============================================
  // ADD DRIVER
  // ============================================

  Future<void> addDriver() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4F8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Register Driver',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter driver name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter phone number'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: vehicleController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Registration',
                      prefixIcon: Icon(Icons.local_taxi_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter vehicle registration'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                setState(() {
                  drivers.add(
                    CompanyDriver(
                      id: 'driver_${nextDriverId++}',
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      vehicleNumber: vehicleController.text
                          .trim()
                          .toUpperCase(),
                    ),
                  );
                });

                Navigator.pop(dialogContext);
                showMessage('Driver registered successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Driver'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    vehicleController.dispose();
  }

  // ============================================
  // CHANGE AVAILABILITY
  // ============================================

  void updateDriverStatus(CompanyDriver driver, String status) {
    if (driver.status == 'On Trip') {
      showMessage('Complete the current trip before changing status');
      return;
    }

    setState(() {
      driver.status = status;
    });
  }

  // ============================================
  // ASSIGN BOOKING TO DRIVER
  // ============================================

  Future<void> assignDriver(CompanyDriver driver) async {
    if (driver.status != 'Available') {
      showMessage('This driver is not available');
      return;
    }

    final bookingController = TextEditingController();
    final pickupController = TextEditingController();
    final destinationController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4F8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Assign Booking',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver: ${driver.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bookingController,
                    decoration: const InputDecoration(
                      labelText: 'Booking Reference',
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter booking reference'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.green,
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter pickup location'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter destination'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                if (driver.status != 'Available') {
                  Navigator.pop(dialogContext);
                  showMessage('Driver is no longer available');
                  return;
                }

                final bookingRef = bookingController.text.trim();

                final alreadyAssigned = drivers.any(
                  (d) => d.bookingId == bookingRef,
                );

                if (alreadyAssigned) {
                  showMessage('This booking is already assigned');
                  return;
                }

                setState(() {
                  driver.bookingId = bookingRef;
                  driver.pickup = pickupController.text.trim();
                  driver.destination = destinationController.text.trim();
                  driver.status = 'On Trip';
                });

                Navigator.pop(dialogContext);

                showMessage('Booking assigned to ${driver.name}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign Driver'),
            ),
          ],
        );
      },
    );

    bookingController.dispose();
    pickupController.dispose();
    destinationController.dispose();
  }

  // ============================================
  // COMPLETE TRIP
  // ============================================

  Future<void> completeTrip(CompanyDriver driver) async {
    if (driver.status != 'On Trip') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Complete Trip?'),
          content: Text(
            'Confirm that ${driver.name} has completed '
            'booking ${driver.bookingId ?? ""}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      driver.status = 'Available';
      driver.bookingId = null;
      driver.pickup = null;
      driver.destination = null;
    });

    showMessage('${driver.name} is now available');
  }

  // ============================================
  // REMOVE DRIVER
  // ============================================

  Future<void> removeDriver(CompanyDriver driver) async {
    if (driver.status == 'On Trip') {
      showMessage('Complete the current trip before removing this driver');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Driver?'),
          content: Text('Remove ${driver.name} from the company?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        drivers.remove(driver);
      });

      showMessage('Driver removed');
    }
  }

  // ============================================
  // DASHBOARD STATISTICS
  // ============================================

  Widget buildStatCard({
    required String title,
    required int number,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: buildGlassCard(
        light: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
        child: Column(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 7),
            Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // DRIVER FILTER BUTTONS
  // ============================================

  Widget buildFilters() {
    final filters = ['All', 'Available', 'On Trip', 'Offline'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: blue,
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              labelStyle: TextStyle(
                color: selected ? Colors.white : navy,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================
  // DRIVER INFORMATION CARD
  // ============================================

  Widget buildDriverCard(CompanyDriver driver) {
    final color = statusColor(driver.status);
    final isBusy = driver.status == 'On Trip';
    final isAvailable = driver.status == 'Available';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DRIVER NAME AND STATUS
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: blue.withValues(alpha: 0.12),
                  child: Icon(Icons.person_rounded, color: blue, size: 28),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.vehicleNumber,
                        style: const TextStyle(
                          color: Color(0xFF68778E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: color, size: 8),
                      const SizedBox(width: 5),
                      Text(
                        driver.status,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 17,
                  color: Color(0xFF68778E),
                ),
                const SizedBox(width: 8),
                Text(
                  driver.phone,
                  style: const TextStyle(
                    color: Color(0xFF35445A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            // ==================================
            // BUSY DRIVER - ACTIVE TRIP DETAILS
            // ==================================
            if (isBusy) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1DF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: orange.withValues(alpha: 0.30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_taxi_rounded, color: orange, size: 19),
                        const SizedBox(width: 8),
                        const Text(
                          'CURRENTLY ON A TRIP',
                          style: TextStyle(
                            color: Color(0xFFB96500),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Booking: ${driver.bookingId ?? "—"}',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.trip_origin,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            driver.pickup ?? 'Pickup unavailable',
                            style: TextStyle(color: navy, fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            driver.destination ?? 'Destination unavailable',
                            style: TextStyle(color: navy, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 13),

            // ==================================
            // DRIVER ACTIONS
            // ==================================
            if (isBusy)
              SizedBox(
                width: double.infinity,
                height: 43,
                child: ElevatedButton.icon(
                  onPressed: () => completeTrip(driver),
                  icon: const Icon(Icons.check_circle_outline, size: 19),
                  label: const Text('Complete Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        updateDriverStatus(
                          driver,
                          isAvailable ? 'Offline' : 'Available',
                        );
                      },
                      icon: Icon(
                        isAvailable ? Icons.power_settings_new : Icons.wifi,
                        size: 17,
                      ),
                      label: Text(
                        isAvailable ? 'Go Offline' : 'Set Available',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: BorderSide(color: blue.withValues(alpha: 0.30)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAvailable
                          ? () => assignDriver(driver)
                          : null,
                      icon: const Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 17,
                      ),
                      label: const Text(
                        'Assign',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => removeDriver(driver),
                  icon: const Icon(Icons.delete_outline, size: 17),
                  label: const Text('Remove Driver'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // EMPTY DRIVER LIST
  // ============================================

  Widget buildEmptyState() {
    return buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 55,
              color: Color(0xFF9BA9BC),
            ),
            const SizedBox(height: 12),
            Text(
              drivers.isEmpty
                  ? 'No drivers registered'
                  : 'No $selectedFilter drivers',
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              drivers.isEmpty
                  ? 'Add your first driver to get started.'
                  : 'Try selecting another filter.',
              style: const TextStyle(color: Color(0xFF68778E), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MAIN DRIVERS PAGE
  // ============================================

  @override
  Widget build(BuildContext context) {
    final visibleDrivers = filteredDrivers;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Manage Drivers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              'Monitor availability and assign trips',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),

          const SizedBox(height: 22),

          // ==================================
          // LIVE STATUS SUMMARY (LOCAL DATA)
          // ==================================
          Row(
            children: [
              buildStatCard(
                title: 'Total',
                number: totalDrivers,
                icon: Icons.people_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 7),
              buildStatCard(
                title: 'Available',
                number: availableDrivers,
                icon: Icons.check_circle_rounded,
                color: green,
              ),
              const SizedBox(width: 7),
              buildStatCard(
                title: 'On Trip',
                number: busyDrivers,
                icon: Icons.local_taxi_rounded,
                color: orange,
              ),
              const SizedBox(width: 7),
              buildStatCard(
                title: 'Offline',
                number: offlineDrivers,
                icon: Icons.power_settings_new,
                color: Colors.white70,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ADD DRIVER BUTTON
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton.icon(
              onPressed: addDriver,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text(
                'Add Driver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Company Drivers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // FILTER BUTTONS
          buildFilters(),

          const SizedBox(height: 14),

          // DRIVER LIST
          if (visibleDrivers.isEmpty)
            buildEmptyState()
          else
            ...visibleDrivers.map(buildDriverCard),
        ],
      ),
    );
  }
}
