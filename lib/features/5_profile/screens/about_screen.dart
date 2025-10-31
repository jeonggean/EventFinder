import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EventFinder',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi ini dibuat sebagai bagian dari Tugas Akhir mata kuliah Pemrograman Aplikasi Mobile.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'Fitur Utama:',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(Icons.search, 'Pencarian Event Konser'),
            _buildFeatureItem(
              Icons.location_on,
              'Pencarian Berbasis Lokasi (LBS)',
            ),
            _buildFeatureItem(
              Icons.favorite,
              'Simpan Event Favorit (Database Hive)',
            ),
            _buildFeatureItem(Icons.calculate, 'Konverter Mata Uang'),
            _buildFeatureItem(Icons.access_time, 'Perbandingan Zona Waktu'),
            _buildFeatureItem(Icons.login, 'Autentikasi User (Login/Register)'),
            _buildFeatureItem(Icons.person, 'Halaman Profil'),
            const SizedBox(height: 24),
            Text(
              'Kesan & Pesan:',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(Tulis kesan dan pesanmu selama mengerjakan project ini di sini...)',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.nunito(fontSize: 16))),
        ],
      ),
    );
  }
}
