import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/parking_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/parking_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/bottom_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int index = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(parkingProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final parkingState = ref.watch(parkingProvider);

    final userName = auth.user?.userMetadata?['nom']?.toString() ?? 'Marc';

    return Scaffold(
      backgroundColor: AppColors.surface,
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bonjour, $userName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: AppStrings.mapPlaceholderSearch,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.mic,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: parkingState.loading
                  ? const LoadingWidget()
                  : parkingState.error != null
                      ? Center(
                          child: Text(
                            parkingState.error!,
                            style: const TextStyle(color: AppColors.red),
                          ),
                        )
                      : (() {
                          final query =
                              _searchController.text.trim().toLowerCase();

                          final filtered = query.isEmpty
                              ? parkingState.parkings
                              : parkingState.parkings
                                  .where((p) => p.nom
                                      .toLowerCase()
                                      .contains(query) ||
                                      p.adresse.toLowerCase().contains(query))
                                  .toList();

                          if (filtered.isEmpty) {
                            return const EmptyStateWidget(
                              text: 'Aucun parking trouvé',
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ParkingCard(
                                  title: p.nom,
                                  subtitle: p.adresse,
                                  pricePerHour: '—',
                                  statusText: 'Libre',
                                  statusType: StatusBadgeType.free,
                                  onTap: () {
                                    context.push('/carte', extra: {
                                      'parkingId': p.id,
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        }()),
            ),
          ],
        ),
      ),
    );
  }
}

