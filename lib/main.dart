import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/core/router.dart';
import 'package:memorise_mobile/core/theme.dart';
import 'package:memorise_mobile/data/repositories/auth_repository.dart';
import 'package:memorise_mobile/data/repositories/memory_repository.dart';
import 'package:memorise_mobile/data/repositories/photo_repository.dart';
import 'package:memorise_mobile/data/repositories/user_repository.dart';
import 'package:memorise_mobile/data/services/api_service.dart';
import 'package:memorise_mobile/data/services/auth_service.dart';
import 'package:memorise_mobile/data/services/snackbar_service.dart';
import 'package:memorise_mobile/data/services/upload_service.dart';
import 'package:memorise_mobile/ui/auth/view_models/login_view_model.dart';
import 'package:memorise_mobile/ui/auth/view_models/logout_view_model.dart';
import 'package:memorise_mobile/ui/home/view_models/home_view_model.dart';
import 'package:memorise_mobile/ui/home/view_models/memory_detail_screen_view_model.dart';
import 'package:memorise_mobile/ui/home/view_models/my_memories_screen_view_model.dart';
import 'package:memorise_mobile/ui/memories/view_models/create_memory_view_model.dart';
import 'package:memorise_mobile/ui/memories/view_models/upload_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/edit_user_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/friend_add_row_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/friend_list_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/memory_invite_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/user_card_view_model.dart';
import 'package:memorise_mobile/ui/user/view_models/user_screen_view_model.dart';
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
        Provider(create: (_) => UploadService()),
        // 2. Initialize Repositories (Inject Service)
        ProxyProvider<AuthService, AuthRepository>(
          update: (_, service, __) => AuthRepository(service),
        ),
        ProxyProvider2<UploadService, ApiService, PhotoRepository>(
          update: (context, uploadService, apiService, previous) =>
              PhotoRepository(uploadService, apiService),
        ),
        Provider(
          create: (context) => MemoryRepository(context.read<ApiService>()),
        ),
        // In MultiProvider:
        ChangeNotifierProvider(create: (_) => UserRepository(ApiService())),
        // 3. Initialize ViewModels (Inject Repository)
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              UserScreenViewModel(context.read<UserRepository>())
                ..fetchUserData(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserCardViewModel(
            context.read<UserRepository>(),
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FriendAddViewModel(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FriendListViewModel(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EditUserViewModel(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => LogoutViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MemoryViewModel(context.read<MemoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MemoryDetailViewModel(context.read<MemoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UploadViewModel(context.read<PhotoRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MemoryInviteViewModel(context.read<MemoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MemoryCreationViewModel(context.read<MemoryRepository>()),
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
      scaffoldMessengerKey: SnackBarService.messengerKey,
      title: 'Memorise',
      theme: MemoriseTheme.lightTheme,
    );
  }
}
