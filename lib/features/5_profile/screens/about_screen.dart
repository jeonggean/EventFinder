import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EvenFinder: Event Finder & Rewards',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi ini adalah platform pencari acara (festival, konser, pameran) yang dibuat sebagai Tugas Akhir. '
              'Aplikasi ini tidak hanya memberi informasi, tapi juga memberi reward kepada pengguna atas partisipasi mereka melalui sistem gamifikasi (Poin & Badge).',
              style: GoogleFonts.nunito(
                fontSize: 17,
                height: 1.5,
                color: AppColors.kTextColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Fitur Utama:',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.kCardColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(Icons.login,
                      'Autentikasi & Sesi Pengguna (Enkripsi Bcrypt)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(Icons.home_filled,
                      'Halaman Utama dengan LBS (Regional & Global)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(
                      Icons.search, 'Pencarian Acara (API Ticketmaster)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(
                      Icons.favorite, 'Database Favorit (SQLite)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(Icons.currency_exchange,
                      'Konverter Mata Uang (Multi-Currency)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(
                      Icons.access_time, 'Konverter Zona Waktu (Multi-Zone)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(
                      Icons.notifications, 'Notifikasi (Jadwal & Favorit)'),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildFeatureItem(Icons.military_tech,
                      'Gamifikasi (Poin, Badge & Redeem Code)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}