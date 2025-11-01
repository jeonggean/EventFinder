import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saran & Kesan Pesan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kesan",
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.kCardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                "Mata kuliah ini sangat membuka wawasan, terutama dalam memahami bagaimana merancang dan membangun perangkat lunak yang skalabel dan efisien. "
                "Proses belajar dari studi kasus nyata sangat membantu saya menghubungkan teori dengan praktik.",
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  color: AppColors.kTextColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Pesan",
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.kCardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                "Untuk ke depannya, mungkin akan lebih baik jika ada sesi workshop atau live coding tambahan untuk topik-topik yang kompleks seperti arsitektur mikroservis atau CI/CD. "
                "Terima kasih atas bimbingan dan ilmunya selama satu semester ini.",
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  color: AppColors.kTextColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
