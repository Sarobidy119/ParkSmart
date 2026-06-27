import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../presentation/providers/reservation_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/layout/bottom_nav_bar.dart';
import '../../widgets/reservation/reservation_status_badge.dart';

class ReservationListScreen extends ConsumerStatefulWidget {
  const ReservationListScreen({super.key});

  @override
  ConsumerState<ReservationListScreen> createState() =>
      _ReservationListScreenState();
}

class _ReservationListScreenState extends ConsumerState<ReservationListScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      final user = AuthRepository().getCurrentUser();
      if (user != null) {
        ref.read(reservationProvider.notifier).loadByUser(user.id);
      }
    });
  }

  ReservationStatus _mapStatusToEnum(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmee':
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'annulee':
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'terminee':
      case 'completed':
        return ReservationStatus.completed;
      case 'en_attente':
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reservationProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/carte');
              break;
            case 2:
              context.go('/reservation');
              break;
            case 3:
              context.go('/profil');
              break;
          }
        },
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ),
                )
              : state.reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune réservation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Commencez par réserver une place de parking',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => context.go('/carte'),
                            child: const Text(
                              'Voir les parkings',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        final user = AuthRepository().getCurrentUser();
                        if (user != null) {
                          await ref
                              .read(reservationProvider.notifier)
                              .loadByUser(user.id);
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.reservations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final reservation = state.reservations[index];
                          final status =
                              _mapStatusToEnum(reservation.statut);
                          final startDate =
                              reservation.debut.toLocal().toString().substring(0, 10);
                          final startTime =
                              reservation.debut.toLocal().toString().substring(11, 16);
                          final endDate =
                              reservation.fin.toLocal().toString().substring(0, 10);
                          final endTime =
                              reservation.fin.toLocal().toString().substring(11, 16);

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header avec statut
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Réservation #${reservation.id.substring(0, 8)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ReservationStatusBadge(status: status),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Dates et heures
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '$startDate à $startTime - $endDate à $endTime',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Place et véhicule
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_parking,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Place: ${reservation.placeId}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_car,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Véhicule: ${reservation.vehiculeId}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Divider
                                  const Divider(color: AppColors.border),
                                  const SizedBox(height: 12),

                                  // Montant
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Montant payé',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${reservation.montant.toStringAsFixed(0)} Ar',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
