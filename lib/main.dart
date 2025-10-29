import 'package:flutter/material.dart';
import 'features/0_navigation/main_navigation_screen.dart'; 


void main() {
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
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor, 
          elevation: 1, 
          foregroundColor: Colors.white, 
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
        cardTheme: CardThemeData(
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
      home: MainNavigationScreen(), 
    );
  }
}