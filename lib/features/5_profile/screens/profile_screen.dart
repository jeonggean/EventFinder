import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../2_auth/services/auth_service.dart';
import '../../2_auth/screens/login_screen.dart';
import '../models/badge_model.dart';
import 'about_screen.dart';
import 'developer_info_screen.dart';
import 'feedback_screen.dart';
import 'redeem_code_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final username = await _authService.getCurrentUsername();
    final points = await _authService.getCurrentUserPoints();
    return {
      'username': username,
      'points': points,
    };
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
      MaterialPageRoute(builder: (context) => AboutScreen()),
    );
  }

  void _goToDeveloperInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeveloperInfoScreen()),
    );
  }

  void _goToFeedbackScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
    );
  }

  void _goToRedeemCodeScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RedeemCodeScreen()),
    );
    setState(() {
      _userDataFuture = _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final username = snapshot.data?['username'] as String?;
          final points = snapshot.data?['points'] as int? ?? 0;
          final badge = BadgeService.getBadgeForPoints(points);

          return Column(
            children: [
              _buildProfileHeader(username, badge),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildProfileMenu(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String? username, BadgeInfo badge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimaryColor,
            Color.lerp(AppColors.kPrimaryColor, Colors.black, 0.3)!
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Column(
          children: [
             const SizedBox(height: 16),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.kCardColor,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.kPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username ?? 'Pengguna',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    badge.name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.kCardColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            _buildMenuTile(
              icon: Icons.confirmation_number_outlined,
              title: "Tukar Kode Voucher",
              onTap: _goToRedeemCodeScreen,
              color: AppColors.kPrimaryColor,
            ),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 4),
            _buildMenuTile(
              icon: Icons.code,
              title: "Informasi Developer",
              onTap: _goToDeveloperInfoScreen,
              color: Colors.blueAccent,
            ),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 4),
            _buildMenuTile(
              icon: Icons.feedback_outlined,
              title: "Saran dan Kesan Pesan",
              onTap: _goToFeedbackScreen,
              color: Colors.orangeAccent,
            ),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 4),
            _buildMenuTile(
              icon: Icons.info_outline,
              title: "Tentang Aplikasi",
              onTap: _goToAboutScreen,
              color: Colors.green,
            ),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 4),
            _buildMenuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: _logout,
              color: Colors.redAccent,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isLogout = false,
  }) {
    final tileColor = color ?? AppColors.kPrimaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: tileColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tileColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.redAccent : AppColors.kTextColor,
                ),
              ),
            ),
            if (!isLogout)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.kSecondaryTextColor,
              ),
          ],
        ),
      ),
    );
  }
}