import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/church_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request Notification permission for Android 13+ 
  // Required for background audio notification to work without crashing
  if (!kIsWeb) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  await Supabase.initialize(
    url: 'https://qqlteazfetfbrmwcradl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxbHRlYXpmZXRmYnJtd2NyYWRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwNzY2ODAsImV4cCI6MjEwNTY1MjY4MH0.dTtqVXV-48hgbGZ1_-XZHMbRAurpsbFHZHU079fqMUc',
  );


  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.eglise.eglise_app.channel.audio',
      androidNotificationChannelName: 'Lecture Audio',
      androidNotificationOngoing: true,
    );

    // Lock orientation to Portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  
  // Initialize audio session for background playback
  // This is required for just_audio to work correctly with audio_session/audio_service
  // Basic global error logging to help debug device-specific crashes
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  await initializeDateFormatting('fr_FR', null);
    // Customize the "Red Screen of Death" to a friendly error message
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Oups ! Quelque chose s\'est mal passé.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'L\'application a rencontré une erreur inattendue. Veuillez redémarrer.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Simply Navigator.pop until root or restart state
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
      ],
      child: const EgliseApp(),
    ),
  );
}

class EgliseApp extends StatelessWidget {
  const EgliseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Paroisse Digitale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange500,
          primary: AppColors.orange500,
          secondary: AppColors.red700,
          surface: AppColors.slate50,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.slate900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.slate900),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFF1F5F9), width: 1), // slate100
          ),
          color: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// We can keep AuthWrapper for reference or remove it. Let's remove it for clean code.



