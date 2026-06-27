import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/json_parsing.dart';
import '../../../data/repositories/paiement_repository.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../data/repositories/vehicule_repository.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? reservationData;

  const PaymentScreen({super.key, this.reservationData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _confirmPayment() async {
    final data = widget.reservationData;
    final user = Supabase.instance.client.auth.currentUser;
    if (data == null || user == null) {
      setState(() {
        _error = 'Connectez-vous avant de confirmer une reservation.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final vehicle = await VehiculeRepository().create(
        utilisateurId: user.id,
        plaque: data['vehicle'].toString(),
        type: 'voiture',
        marque: '',
        modele: '',
      );

      final reservation = await ReservationRepository().create(
        utilisateurId: user.id,
        parkingId: data['parkingId'].toString(),
        placeId: data['placeId'].toString(),
        vehiculeId: vehicle.id,
        debut: DateTime.parse(data['start'].toString()),
        fin: DateTime.parse(data['end'].toString()),
        montant: jsonDouble(data['amount']),
      );

      await PaiementRepository().create(
        reservationId: reservation.id,
        utilisateurId: user.id,
        methode: 'mobile',
        montant: reservation.montant,
      );

      await Supabase.instance.client
          .from('place_parking')
          .update({'occupe': true}).eq('id', data['placeId'].toString());

      if (!mounted) return;
      context.go('/reservation/confirmation?id=${reservation.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.reservationData?['amount'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('Montant: $amount Ar'),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving ? null : _confirmPayment,
              child:
                  Text(_saving ? 'Confirmation...' : 'Confirmer le paiement'),
            ),
          ],
        ),
      ),
    );
  }
}
