import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/parking_model.dart';
import '../../../data/models/place_parking_model.dart';
import '../../../data/repositories/parking_repository.dart';
import '../../../data/supabase_client.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ParkingDetailScreen extends ConsumerStatefulWidget {
  final String parkingId;

  const ParkingDetailScreen({
    super.key,
    required this.parkingId,
  });

  @override
  ConsumerState<ParkingDetailScreen> createState() =>
      _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends ConsumerState<ParkingDetailScreen> {
  bool _loading = true;
  String? _error;

  ParkingModel? _parking;
  List<PlaceParkingModel> _places = [];

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      selectedIndex = -1;
    });

    try {
      final parkingRepo = ParkingRepository();

      final parking = await parkingRepo.getById(widget.parkingId);

      final supabase = SupabaseClientSingleton().client;

      final placesRes = await supabase
          .from('place_parking')
          .select('*')
          .eq('parking_id', widget.parkingId);

      final places = (placesRes as List<dynamic>? ?? [])
          .map((e) => PlaceParkingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _parking = parking;
        _places = places;
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

  bool _isPlaceAvailable(PlaceParkingModel p) {
    // HTML used colors based on "available" vs "occupied".
    // Model contains occupe (true => occupied). We'll treat occupe==false => available.
    return !p.occupe;
  }

  @override
  Widget build(BuildContext context) {
    final parking = _parking;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(parking?.nom ?? 'Parking'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (selectedIndex < 0 || selectedIndex >= _places.length) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez choisir une place')),
                );
                return;
              }

              final place = _places[selectedIndex];
              final available = _isPlaceAvailable(place);
              if (!available) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cette place n’est pas disponible')),
                );
                return;
              }

              context.push(
                '/reservation/new?parkingId=${widget.parkingId}',
                extra: {
                  'placeId': place.id,
                },
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Réserver une place'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget()
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : parking == null
                    ? const EmptyStateWidget()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 6),
                                child: Text(
                                  parking.nom,
                                  style: AppTheme.themeData()
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Text(
                                  parking.adresse,
                                  style: AppTheme.themeData()
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Disponibilité',
                                  style: AppTheme.themeData()
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 12)),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildPlacesGrid(),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 18)),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Informations importantes',
                                  style: AppTheme.themeData()
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    _InfoLine(
                                      icon: Icons.check_circle,
                                      text:
                                          'Entrée par reconnaissance de plaque.',
                                    ),
                                    SizedBox(height: 8),
                                    _InfoLine(
                                      icon: Icons.check_circle,
                                      text:
                                          'Annulation gratuite jusqu\'à 15 min avant.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 90)),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildPlacesGrid() {
    if (_places.isEmpty) {
      return const EmptyStateWidget(text: 'Aucune place');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _places.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 56,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, i) {
        final pl = _places[i];
        final available = _isPlaceAvailable(pl);
        final selected = selectedIndex == i;

        final bg = available
            ? (selected ? AppColors.primary : AppColors.primaryLight)
            : AppColors.surface;

        final borderColor = available
            ? (selected ? AppColors.primary : AppColors.border)
            : AppColors.border;

        final fg = available
            ? (selected ? AppColors.white : AppColors.primaryDark)
            : AppColors.textSecondary;

        return InkWell(
          onTap: available ? () => setState(() => selectedIndex = i) : null,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Center(
              child: Text(
                pl.numero,
                style: const TextStyle(
                  fontSize: 10,
                  height: 12 / 10,
                  fontWeight: FontWeight.w500,
                ).copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.themeData()
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
