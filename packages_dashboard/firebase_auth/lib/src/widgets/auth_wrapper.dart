import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Widget that wraps content and handles authentication state
///
/// Automatically shows login screen when user is not authenticated
/// and shows the child widget when authenticated.
///
/// Usage with context.watch:
/// ```dart
/// final isAuthenticated = ref.watch(isAuthenticatedProvider);
/// if (!isAuthenticated) {
///   return LoginScreen();
/// }
/// return HomeScreen();
/// ```
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  final Widget Function(BuildContext context)? signedOutBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const AuthWrapper({
    Key? key,
    required this.child,
    this.signedOutBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseUserStreamProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return signedOutBuilder?.call(context) ??
              const Center(
                child: Text('Por favor, faça login'),
              );
        }
        return child;
      },
      loading: () {
        return loadingBuilder?.call(context) ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
      error: (error, stack) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Erro de autenticação: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Refresh the provider
                    ref.invalidate(firebaseUserStreamProvider);
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple authentication check widget
/// Returns true if user is authenticated, false otherwise
class AuthChecker extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isAuthenticated) builder;

  const AuthChecker({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    return builder(context, isAuthenticated);
  }
}

/// Widget that only shows content if user has required role
class RoleGuard extends ConsumerWidget {
  final String requiredRole;
  final Widget child;
  final Widget Function(BuildContext context)? unauthorizedBuilder;

  const RoleGuard({
    Key? key,
    required this.requiredRole,
    required this.child,
    this.unauthorizedBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Por favor, faça login'));
        }

        if (user.hasRole(requiredRole)) {
          return child;
        }

        return unauthorizedBuilder?.call(context) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Permissão necessária: $requiredRole'),
                ],
              ),
            );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro: $error')),
    );
  }
}
