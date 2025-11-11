import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_auth.dart';

/// Example main.dart showing how to use the firebase_auth package
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseInitService.initialize(
    apiKey: 'YOUR_API_KEY',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdef',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(
        child: HomeScreen(),
        signedOutBuilder: AuthScreen.new,
      ),
    );
  }
}

/// Auth screen with login/register toggle
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen(BuildContext context, {Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showLogin ? 'Login' : 'Cadastro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _showLogin
                ? LoginWidget(
                    onRegisterTap: () {
                      setState(() {
                        _showLogin = false;
                      });
                    },
                  )
                : RegisterWidget(
                    onLoginTap: () {
                      setState(() {
                        _showLogin = true;
                      });
                    },
                    onRegisterSuccess: () {
                      setState(() {
                        _showLogin = true;
                      });
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

/// Home screen shown after authentication
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Carregando...'));
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Email: ${user.email}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (user.displayName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nome: ${user.displayName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'UID: ${user.uid}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (user.role != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('Role: ${user.role}'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!user.emailVerified)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Email não verificado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Por favor, verifique seu email para confirmar sua conta.',
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(authServiceProvider)
                                      .sendEmailVerification();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email de verificação enviado!'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('Reenviar Email'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
