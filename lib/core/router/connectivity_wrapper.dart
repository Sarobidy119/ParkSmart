import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/connectivity_provider.dart';
import '../../presentation/screens/no_internet/no_internet_screen.dart';

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    // Affiche la page no internet si pas de connexion
    // mais pas sur la page no_internet elle-même pour éviter une boucle
    if (!connectivity.isConnected) {
      return const NoInternetScreen();
    }

    return child;
  }
}
