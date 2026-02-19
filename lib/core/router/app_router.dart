import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone_assignment/features/home/presentation/screens/main_screen.dart';
import 'package:pinterest_clone_assignment/features/home/presentation/screens/pin_detail_screen.dart';
import 'package:pinterest_clone_assignment/features/saved/presentation/screens/profile_screen.dart';

class PinDetailParams {
  final String imageUrl;
  final String? originalImageUrl;
  final int index;
  final double aspectRatio;
  final String? photographer;
  final String? alt;

  PinDetailParams({
    required this.imageUrl,
    this.originalImageUrl,
    required this.index,
    required this.aspectRatio,
    this.photographer,
    this.alt,
  });
}

class AppRouter {
  static const String main = '/';
  static const String pinDetail = '/pin';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: main,
    routes: [
      GoRoute(
        path: main,
        builder: (context, state) {
          return ClerkErrorListener(
            child: ClerkAuthBuilder(
              signedInBuilder: (context, authState) => const MainScreen(),
              signedOutBuilder: (context, authState) => Scaffold(
                body: const SafeArea(
                  child: Center(child: ClerkAuthentication()),
                ),
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: pinDetail,
        builder: (context, state) {
          final params = state.extra as PinDetailParams;

          return PinDetailScreen(
            imageUrl: params.imageUrl,
            originalImageUrl: params.originalImageUrl,
            index: params.index,
            aspectRatio: params.aspectRatio,
            photographer: params.photographer,
            alt: params.alt,
          );
        },
      ),

      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
