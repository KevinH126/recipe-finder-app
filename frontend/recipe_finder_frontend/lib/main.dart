import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );


  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      builder: DevicePreview.appBuilder,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? LoginScreen() : HomeScreen();
  }
}