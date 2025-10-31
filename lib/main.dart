import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'features/0_navigation/main_navigation_screen.dart';
import 'features/2_auth/services/auth_service.dart';
import 'features/2_auth/screens/login_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('session');
  await Hive.openBox('users');
  await Hive.openBox('favorites');

  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Finder (MVC)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.kBackgroundColor,
        primaryColor: AppColors.kPrimaryColor,
        cardColor: AppColors.kCardColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.kPrimaryColor,
          secondary: AppColors.kAccentColor,
          onSurface: AppColors.kTextColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.kBackgroundColor,
          foregroundColor: AppColors.kTextColor,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: AppColors.kTextColor,
            fontSize: 20,
          ),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme)
            .apply(
          bodyColor: AppColors.kTextColor,
          displayColor: AppColors.kTextColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              textStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        cardTheme: CardThemeData(
          clipBehavior: Clip.antiAlias,
          color: AppColors.kCardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (_authService.isLoggedIn()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
      color: AppColors.kPrimaryColor,
    )));
  }
}