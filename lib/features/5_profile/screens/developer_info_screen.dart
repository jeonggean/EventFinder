import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Developer Info"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/dev_profile.jpg'),
              ),
              const SizedBox(height: 24),
              Text(
                "Jeonggean",
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Software Engineering Student",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: AppColors.kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined,
                      color: AppColors.kSecondaryTextColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "email.developer@example.com",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.kTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}