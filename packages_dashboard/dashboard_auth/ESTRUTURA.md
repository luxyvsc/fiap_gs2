# Firebase Auth Flutter Package - Estrutura Completa

## 📁 Estrutura de Arquivos

```
packages_dashboard/firebase_auth/
├── lib/
│   ├── firebase_auth.dart              # Arquivo principal de exportação
│   ├── example.dart                    # Exemplo completo de uso
│   │
│   └── src/
│       ├── models/
│       │   └── auth_user_model.dart    # Modelo de usuário com claims
│       │
│       ├── services/
│       │   ├── firebase_init_service.dart  # Inicialização do Firebase
│       │   └── auth_service.dart           # Operações de autenticação
│       │
│       ├── providers/
│       │   └── auth_provider.dart      # Providers Riverpod
│       │
│       └── widgets/
│           ├── login_widget.dart       # Widget de login
│           ├── register_widget.dart    # Widget de cadastro
│           └── auth_wrapper.dart       # Wrapper de autenticação
│
├── test/
│   └── firebase_auth_test.dart         # Testes
│
├── pubspec.yaml                        # Dependências
├── README.md                           # Documentação
├── CHANGELOG.md                        # Histórico de versões
└── analysis_options.yaml               # Configuração de análise
```

## 🎯 Componentes Principais

### 1. FirebaseInitService
**Arquivo:** `lib/src/services/firebase_init_service.dart`

**Função:** Inicializar Firebase no app Flutter

**Uso:**
```dart
await FirebaseInitService.initialize(
  apiKey: 'YOUR_API_KEY',
  authDomain: 'your-project.firebaseapp.com',
  projectId: 'your-project-id',
  storageBucket: 'your-project.appspot.com',
  messagingSenderId: '123456789',
  appId: '1:123456789:web:abcdef',
);
```

### 2. AuthService
**Arquivo:** `lib/src/services/auth_service.dart`

**Função:** Operações de autenticação (login, register, etc.)

**Métodos principais:**
- `signInWithEmailAndPassword(email, password)` - Login
- `createUserWithEmailAndPassword(email, password, displayName)` - Cadastro
- `sendPasswordResetEmail(email)` - Recuperar senha
- `sendEmailVerification()` - Enviar verificação de email
- `signOut()` - Logout
- `get currentUser` - Usuário atual
- `get isSignedIn` - Está logado?

### 3. Providers (Riverpod)
**Arquivo:** `lib/src/providers/auth_provider.dart`

**Providers disponíveis:**

#### `authServiceProvider`
Provider do serviço de autenticação
```dart
final authService = ref.read(authServiceProvider);
```

#### `authStateNotifierProvider`
StateNotifier para operações de auth com loading states
```dart
final notifier = ref.read(authStateNotifierProvider.notifier);
await notifier.signIn(email, password);
await notifier.register(email, password, name);
await notifier.resetPassword(email);
await notifier.signOut();
```

#### `isAuthenticatedProvider`
Verifica se usuário está logado (USE COM ref.watch!)
```dart
final isAuth = ref.watch(isAuthenticatedProvider);
if (!isAuth) {
  return LoginScreen();
}
return HomeScreen();
```

#### `firebaseUserStreamProvider`
Stream do usuário do Firebase
```dart
final userStream = ref.watch(firebaseUserStreamProvider);
```

#### `authUserStreamProvider`
Stream do usuário com custom claims
```dart
final userStream = ref.watch(authUserStreamProvider);
```

### 4. LoginWidget
**Arquivo:** `lib/src/widgets/login_widget.dart`

**Widget pronto para usar com:**
- Campo de email
- Campo de senha com toggle de visibilidade
- Validação de formulário
- Botão "Esqueceu a senha?"
- Botão de login com loading
- Link para cadastro

**Uso:**
```dart
LoginWidget(
  onRegisterTap: () {
    // Navegar para tela de cadastro
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => RegisterScreen(),
    ));
  },
  onLoginSuccess: () {
    // Opcional: ação após login bem-sucedido
    print('Login realizado!');
  },
)
```

### 5. RegisterWidget
**Arquivo:** `lib/src/widgets/register_widget.dart`

**Widget pronto para usar com:**
- Campo de nome completo
- Campo de email
- Campo de senha com toggle de visibilidade
- Campo de confirmar senha
- Validação de formulário
- Verificação se senhas coincidem
- Botão de cadastro com loading
- Link para login

**Uso:**
```dart
RegisterWidget(
  onLoginTap: () {
    // Voltar para login
    Navigator.pop(context);
  },
  onRegisterSuccess: () {
    // Após cadastro, voltar para login
    Navigator.pop(context);
  },
)
```

### 6. AuthWrapper
**Arquivo:** `lib/src/widgets/auth_wrapper.dart`

**Wrapper que gerencia estado de autenticação automaticamente**

**Uso:**
```dart
// No MaterialApp
return MaterialApp(
  home: AuthWrapper(
    child: HomeScreen(),  // Mostrado quando logado
    signedOutBuilder: (context) => LoginScreen(),  // Quando não logado
    loadingBuilder: (context) => LoadingScreen(),  // Enquanto verifica
  ),
);
```

**Widgets adicionais:**
- `AuthChecker` - Builder para verificação condicional
- `RoleGuard` - Proteger por role (admin, user, etc.)

## 🚀 Exemplo Completo de Uso

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar Firebase
  await FirebaseInitService.initialize(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 2. Usar AuthWrapper para gerenciar autenticação
      home: const AuthWrapper(
        child: HomeScreen(),
        signedOutBuilder: AuthScreen.new,
      ),
    );
  }
}

// Tela de autenticação (login/cadastro)
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
                    onRegisterTap: () => setState(() => _showLogin = false),
                  )
                : RegisterWidget(
                    onLoginTap: () => setState(() => _showLogin = true),
                    onRegisterSuccess: () => setState(() => _showLogin = true),
                  ),
          ),
        ),
      ),
    );
  }
}

// Tela principal (após login)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Usar context.watch para obter dados do usuário
    final userAsync = ref.watch(authUserStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 4. Logout
              await ref.read(authStateNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Carregando...'));
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bem-vindo!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text('Email: ${user.email}'),
                if (user.displayName != null)
                  Text('Nome: ${user.displayName}'),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
```

## 🔍 Verificando Estado de Autenticação

### Método 1: AuthWrapper (Recomendado)
```dart
return AuthWrapper(
  child: HomeScreen(),
  signedOutBuilder: (context) => LoginScreen(),
);
```

### Método 2: context.watch manual
```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);

if (!isAuthenticated) {
  return const LoginScreen();
}
return const HomeScreen();
```

### Método 3: AuthChecker builder
```dart
return AuthChecker(
  builder: (context, isAuthenticated) {
    return isAuthenticated ? HomeScreen() : LoginScreen();
  },
);
```

## 🎨 Recursos dos Widgets

### LoginWidget
✅ Validação de email
✅ Validação de senha (mínimo 6 caracteres)
✅ Toggle de visibilidade da senha
✅ Recuperação de senha
✅ Loading states
✅ Mensagens de erro em português
✅ Link para cadastro

### RegisterWidget
✅ Validação de nome (mínimo 3 caracteres)
✅ Validação de email
✅ Validação de senha (mínimo 6 caracteres)
✅ Confirmação de senha
✅ Toggle de visibilidade das senhas
✅ Envio automático de verificação de email
✅ Loading states
✅ Mensagens de erro em português
✅ Link para login

## 🔐 Mensagens de Erro (Português)

Todas as mensagens de erro do Firebase foram traduzidas:
- "Nenhum usuário encontrado com este email."
- "Senha incorreta."
- "Já existe uma conta com este email."
- "Email inválido."
- "A senha é muito fraca. Use pelo menos 6 caracteres."
- "Esta conta foi desabilitada."
- "Muitas tentativas. Tente novamente mais tarde."
- E mais...

## 📝 Checklist de Implementação

Para usar em seu app:

1. ✅ Adicionar dependência no pubspec.yaml
2. ✅ Configurar Firebase no console
3. ✅ Obter credenciais (API key, etc.)
4. ✅ Inicializar Firebase no main()
5. ✅ Envolver app com ProviderScope
6. ✅ Usar AuthWrapper na home
7. ✅ Criar tela com LoginWidget/RegisterWidget
8. ✅ Usar ref.watch(isAuthenticatedProvider) onde necessário

## 🎉 Pronto para Usar!

Todos os 5 itens solicitados foram implementados:
1. ✅ Funções para iniciar Firebase
2. ✅ Provider Riverpod completo
3. ✅ Widget de login
4. ✅ Widget de cadastro
5. ✅ context.watch para verificar autenticação
