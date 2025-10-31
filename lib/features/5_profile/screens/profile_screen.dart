import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../2_auth/services/auth_service.dart';
import '../../2_auth/screens/login_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    _username = _authService.getCurrentUser();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _goToAboutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 1),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _username ?? 'Pengguna',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
            Text(
              'Selamat datang kembali!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.kSecondaryTextColor,
              ),
            ),
            const Spacer(flex: 2),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Tentang Aplikasi'),
              onPressed: _goToAboutScreen,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}