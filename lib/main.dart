import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bcrypt/bcrypt.dart'; 

import 'features/0_navigation/main_navigation_screen.dart';
import 'features/2_auth/services/auth_service.dart';
import 'features/2_auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final appDocumentDir = await getApplicationDocumentsDirectory();
  
  await Hive.initFlutter(appDocumentDir.path); 
  
  await Hive.openBox('session');
  await Hive.openBox('users');
  await Hive.openBox('favorites'); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final Color primaryColor = Color(0xFF9575CD); 
    final Color backgroundColor = Color(0xFFF9F9F9); 
    final Color cardColor = Color(0xFFFFFFFF); 
    final Color primaryTextColor = Color(0xFF333333); 
    final Color secondaryTextColor = Color(0xFF828282); 

    return MaterialApp(
      title: 'Event Finder (MVC)',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        brightness: Brightness.light, 
        primaryColor: primaryColor, 
        scaffoldBackgroundColor: backgroundColor, 
        
        fontFamily: GoogleFonts.nunito().fontFamily,

        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor, 
          elevation: 1, 
          foregroundColor: Colors.white, 
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white, 
            fontSize: 22, 
            fontWeight: FontWeight.bold
          ),
        ),
        
        cardTheme: CardThemeData( 
          clipBehavior: Clip.antiAlias,
          color: cardColor, 
          elevation: 2, 
          shadowColor: Colors.grey.withOpacity(0.2), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, 
            foregroundColor: Colors.white, 
          ),
        ),
        iconTheme: IconThemeData(
          color: secondaryTextColor, 
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,        
          background: backgroundColor,  
          surface: cardColor,         
          onPrimary: Colors.white,      
          onBackground: primaryTextColor,   
          onSurface: primaryTextColor,      
          secondary: primaryColor,      
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}