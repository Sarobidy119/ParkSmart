import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/parking/parking_detail_screen.dart';
import '../../presentation/screens/reservation/reservation_form_screen.dart';
import '../../presentation/screens/reservation/reservation_list_screen.dart';
import '../../presentation/screens/reservation/reservation_confirmation_screen.dart';
import '../../presentation/screens/payment/payment_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/vehicle/vehicle_screen.dart';
import '../../presentation/screens/notification/notification_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(child: Text('Erreur: ${state.error}')),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/carte',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final parkingId = extra?['parkingId']?.toString();
          return MapScreen(initialParkingId: parkingId);
        },
      ),
      GoRoute(
        path: '/parking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ParkingDetailScreen(parkingId: id);
        },
      ),
      GoRoute(
        path: '/reservation/new',
        builder: (context, state) {
          final parkingId = state.uri.queryParameters['parkingId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ReservationFormScreen(
            parkingId: parkingId,
            placeId: extra?['placeId']?.toString(),
          );
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          return PaymentScreen(
              reservationData: state.extra as Map<String, dynamic>?);
        },
      ),
      GoRoute(
        path: '/reservation/confirmation',
        builder: (context, state) {
          return ReservationConfirmationScreen(
              reservationId: state.uri.queryParameters['id']);
        },
      ),
      GoRoute(
        path: '/reservation',
        builder: (context, state) => const ReservationListScreen(),
      ),
      GoRoute(
        path: '/profil',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const VehicleScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
}
