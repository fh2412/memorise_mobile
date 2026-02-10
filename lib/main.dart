import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/core/router.dart';
import 'package:memorise_mobile/core/theme.dart';
import 'package:memorise_mobile/data/repositories/auth_repository.dart';
import 'package:memorise_mobile/data/repositories/user_repository.dart';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/data/services/auth_service.dart';
import 'package:memorise_mobile/ui/auth/view_models/login_view_model.dart';
import 'package:memorise_mobile/ui/home/view_models/home_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. Initialize Services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
        // 2. Initialize Repositories (Inject Service)
        ProxyProvider<AuthService, AuthRepository>(
          update: (_, service, __) => AuthRepository(service),
        ),
        ProxyProvider<ApiService, UserRepository>(
          update: (_, api, __) => UserRepository(api),
        ),
        // 3. Initialize ViewModels (Inject Repository)
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            context.read<UserRepository>(),
            context.read<AuthRepository>(),
          )..fetchUserData(),
        ),
      ],
      child: const MemoriseApp(),
    ),
  );
}

class MemoriseApp extends StatelessWidget {
  const MemoriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'Memorise',
      theme: MemoriseTheme.lightTheme,
    );
  }
}
