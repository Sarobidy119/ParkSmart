import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationConfirmationScreen extends StatelessWidget {
  final String? reservationId;

  const ReservationConfirmationScreen({super.key, this.reservationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Reservation confirmee',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Reference: ${reservationId ?? 'locale'}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/reservation'),
              child: const Text('Voir mes reservations'),
            ),
          ],
        ),
      ),
    );
  }
}
