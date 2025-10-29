import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/timezone_helper.dart'; // <-- IMPORT HELPER
import '../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  // Buat instance dari helper
  final TimezoneHelper _timezoneHelper = TimezoneHelper();

  EventDetailScreen({super.key, required this.event});

  String _formatCurrency(double price, String currencyCode) {
    if (price == 0.0 && currencyCode == 'N/A') return "Harga tidak tersedia";
    if (price == 0.0) return "Gratis";

    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: "$currencyCode ",
      decimalDigits: 2,
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final String isoDateTime = _timezoneHelper.getIsoDateTime(
      event.localDate,
      event.localTime,
    );

    final Map<String, String> convertedTimes = _timezoneHelper
        .getConvertedTimes(isoDateTime, event.timezone);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Acara",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    // Tampilkan juga timezone asli event-nya
                    text:
                        "${event.localDate} @ ${event.localTime} (${event.timezone})",
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.attach_money,
                    text: _formatCurrency(event.minPrice, event.currency),
                  ),

                  // --- BAGIAN TAMBAHAN (ZONA WAKTU) ---
                  const SizedBox(height: 24),
                  Text(
                    "Perbandingan Zona Waktu",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildTimezoneRow(
                    "WIB (Jakarta)",
                    convertedTimes['WIB'] ?? 'N/A',
                  ),
                  _buildTimezoneRow(
                    "WITA (Makassar)",
                    convertedTimes['WITA'] ?? 'N/A',
                  ),
                  _buildTimezoneRow(
                    "WIT (Jayapura)",
                    convertedTimes['WIT'] ?? 'N/A',
                  ),
                  _buildTimezoneRow(
                    "London",
                    convertedTimes['London'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  // Widget baru untuk menampilkan perbandingan waktu
  Widget _buildTimezoneRow(String zoneName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zoneName, style: const TextStyle(fontSize: 16)),
          Text(
            time,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
