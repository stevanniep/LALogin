import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kdwnteewgnyocjmdvldv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtkd250ZWV3Z255b2NqbWR2bGR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNDIwNDMsImV4cCI6MjA2NzcxODA0M30.aX9nPN0S15Z8y_z4ghzi11RB7isBQC4zVypolOWU3Oo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
