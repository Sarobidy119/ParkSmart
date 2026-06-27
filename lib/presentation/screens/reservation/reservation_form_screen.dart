import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/place_parking_model.dart';
import '../../../data/supabase_client.dart';

class ReservationFormScreen extends StatefulWidget {
  final String parkingId;
  final String? placeId;

  const ReservationFormScreen({
    super.key,
    required this.parkingId,
    this.placeId,
  });

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _vehicleController = TextEditingController();
  DateTime _start = DateTime.now();
  int _durationHours = 1;
  List<PlaceParkingModel> _places = [];
  String? _selectedPlaceId;
  double _prixHeure = 2000;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedPlaceId = widget.placeId;
    _loadReservationData();
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _loadReservationData() async {
    try {
      final client = SupabaseClientSingleton().client;
      final results = await Future.wait([
        client
            .from('place_parking')
            .select('*')
            .eq('parking_id', widget.parkingId)
            .eq('occupe', false)
            .order('numero', ascending: true),
        client
            .from('tarif')
            .select('*')
            .eq('parking_id', widget.parkingId)
            .maybeSingle(),
      ]);

      final places = (results[0] as List<dynamic>? ?? [])
          .map((item) =>
              PlaceParkingModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final tarif = results[1] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _places = places;
        _prixHeure = (tarif?['prix_heure'] ?? _prixHeure).toDouble();
        _selectedPlaceId ??= places.isNotEmpty ? places.first.id : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final end = _start.add(Duration(hours: _durationHours));
    final amount = _durationHours * _prixHeure;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle reservation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Parking: ${widget.parkingId}'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPlaceId,
                      decoration: const InputDecoration(
                        labelText: 'Place',
                        border: OutlineInputBorder(),
                      ),
                      items: _places
                          .map(
                            (place) => DropdownMenuItem(
                              value: place.id,
                              child: Text('${place.numero} - ${place.niveau}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlaceId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _vehicleController,
                      decoration: const InputDecoration(
                        labelText: 'Plaque du vehicule',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Debut'),
                      subtitle:
                          Text(_start.toLocal().toString().substring(0, 16)),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _start,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date == null || !context.mounted) return;

                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_start),
                        );
                        if (time == null) return;

                        setState(() {
                          _start = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _durationHours,
                      decoration: const InputDecoration(
                        labelText: 'Duree',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) => index + 1)
                          .map(
                            (hours) => DropdownMenuItem(
                              value: hours,
                              child:
                                  Text('$hours heure${hours > 1 ? 's' : ''}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _durationHours = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Fin: ${end.toLocal().toString().substring(0, 16)}'),
                    const SizedBox(height: 8),
                    Text('Montant: ${amount.toStringAsFixed(0)} Ar'),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      onPressed: () {
                        final vehicle = _vehicleController.text.trim();
                        final placeId = _selectedPlaceId;
                        if (placeId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Aucune place disponible.')),
                          );
                          return;
                        }
                        if (vehicle.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Entrez la plaque du vehicule.')),
                          );
                          return;
                        }
                        context.go('/payment', extra: {
                          'parkingId': widget.parkingId,
                          'placeId': placeId,
                          'vehicle': vehicle,
                          'start': _start.toIso8601String(),
                          'end': end.toIso8601String(),
                          'amount': amount,
                        });
                      },
                      child: const Text('Continuer vers le paiement'),
                    ),
                  ],
                ),
    );
  }
}
