import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/colors.dart';
import 'providers/app_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xqxcxapuqzwcjxdvielw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhxeGN4YXB1cXp3Y2p4ZHZpZWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MDI5NDUsImV4cCI6MjA4NTM3ODk0NX0.QB7W8o4TkR4-hW9Atiru_9uqBfZ1B8ic_DFeO7-sRyY',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const ShareCartApp(),
    ),
  );
}

class ShareCartApp extends StatelessWidget {
  const ShareCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareCart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto', 
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        )
      ),
      home: Consumer<AppProvider>(
        builder: (context, provider, _) {
          // If logged in (Vendor/User) or Guest Mode active -> Show Main App
          if (provider.currentUser != null || provider.isGuest) {
            return const MainScreen();
          }
          // Otherwise -> Show Login
          return const LoginScreen();
        },
      ),
    );
  }
}
