import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/parking_model.dart';
import '../../providers/parking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/layout/bottom_nav_bar.dart';
import '../../widgets/map/parking_map_bottom_sheet.dart';
import '../../widgets/map/map_view_controls.dart';
import '../../widgets/map/user_location_indicator.dart';
import '../../widgets/map/route_info_panel.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? initialParkingId;

  const MapScreen({super.key, this.initialParkingId});



  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int index = 1;
  String? selectedParkingId;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parkingProvider.notifier).loadAll();
      // Adresse -> localisation via Nominatim (mode gratuit)
      // (On garde l'appel sans adresse ici: fallback Antananarivo si non renseignée)
      final auth = ref.read(authProvider);
      final user = auth.user;
      final adresse = user?.userMetadata?['adresse']?.toString();
      ref.read(locationProvider.notifier).startTracking(adresse: adresse);

      // Si on arrive depuis Home avec un parking sélectionné, ouvrir directement le bottom sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final id = widget.initialParkingId;
        if (id == null) return;

        final parkingState = ref.read(parkingProvider);
        final parking = parkingState.parkings.firstWhere((p) => p.id == id, orElse: () => parkingState.parkings.first);
        _showParkingDetails(context, parking);
      });
    });
  }

  void _showParkingDetails(BuildContext context, ParkingModel parking) {
    final userLocation =
        ref.read(locationProvider).currentLocation ?? LatLng(-18.9139, 47.5361);

    // Calculer la distance vers ce parking
    ref
        .read(routeProvider.notifier)
        .calculateRoute(userLocation, LatLng(parking.latitude, parking.longitude));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final routeState = ref.watch(routeProvider);
            final route = routeState.route;

            return ParkingMapBottomSheet(
              parkingName: parking.nom,
              parkingAddress: parking.adresse,
              distance: route?.distanceMeters ?? 0,
              duration: route?.durationSeconds ?? 0,
              onReserve: () {
                Navigator.of(ctx).pop();
                context.go('/parking/${parking.id}');
              },
              onRoute: () {
                // Rester dans le bottom sheet et afficher les infos d'itinéraire
                setState(() => selectedParkingId = parking.id);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkingState = ref.watch(parkingProvider);
    final locationState = ref.watch(locationProvider);
    final mapState = ref.watch(mapProvider);
    final routeState = ref.watch(routeProvider);

    final antananarivo = LatLng(-18.9139, 47.5361);
    final userLocation = locationState.currentLocation ?? antananarivo;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        onTap: (i) {
          setState(() => index = i);
          switch (i) {
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
      body: parkingState.loading
          ? const LoadingWidget()
          : parkingState.error != null
              ? Center(
                  child: Text(parkingState.error!,
                      style: const TextStyle(color: AppColors.red)),
                )
              : parkingState.parkings.isEmpty
                  ? const EmptyStateWidget()
                  : Stack(
                      children: [
                        // Carte
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: userLocation,
                            initialZoom: mapState.zoom,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom |
                                  InteractiveFlag.drag,
                            ),
                          ),
                          children: [
                            // Tile Layer avec vue changeable
                            TileLayer(
                              urlTemplate: ref.read(mapProvider.notifier).getTileUrl(),

                              userAgentPackageName: 'parksmart',
                              tileProvider: NetworkTileProvider(),
                            ),

                            // Position utilisateur
                            if (locationState.currentLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: userLocation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_pin_circle,
                                        color: AppColors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // Points de parking
                            MarkerLayer(
                              markers: parkingState.parkings.map((p) {
                                return Marker(
                                  width: 40,
                                  height: 40,
                                  point: LatLng(p.latitude, p.longitude),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showParkingDetails(context, p),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: selectedParkingId == p.id
                                            ? AppColors.warning
                                            : AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.local_parking,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Chemin de l'itinéraire
                            if (routeState.route != null)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routeState.route!.waypoints,
                                    strokeWidth: 4,
                                    color: AppColors.primary.withOpacity(0.7),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        // Contrôles de vue
                        MapViewControls(
                          currentViewType: mapState.viewType,
                          onViewChanged: (type) {
                            ref.read(mapProvider.notifier).setMapViewType(type);
                          },
                        ),

                        // Indicateur de position utilisateur
                        Positioned(
                          top: 16,
                          left: 16,
                          child: UserLocationIndicator(
                            accuracy: locationState.accuracy != null
                                ? 'Précision: ±${locationState.accuracy!.toStringAsFixed(0)}m'
                                : 'Localisation...',
                          ),
                        ),

                        // Panneau d'infos itinéraire
                        RouteInfoPanel(
                          routeInfo: routeState.route,
                          onClose: () => setState(() => selectedParkingId = null),
                        ),
                      ],
                    ),
    );
  }
}

