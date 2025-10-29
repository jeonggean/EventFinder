import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/timezone_helper.dart';
import '../../3_favorites/services/favorites_service.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final TimezoneHelper _timezoneHelper = TimezoneHelper();
  final FavoritesService _favoritesService = FavoritesService();

  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = _favoritesService.isFavorite(widget.event);
  }

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

  void _toggleFavorite() {
    setState(() {
      if (_isFavorite) {
        _favoritesService.removeFavorite(widget.event);
        _isFavorite = false;
      } else {
        _favoritesService.addFavorite(widget.event);
        _isFavorite = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String isoDateTime = _timezoneHelper.getIsoDateTime(
      widget.event.localDate,
      widget.event.localTime,
    );

    final Map<String, String> convertedTimes = _timezoneHelper
        .getConvertedTimes(isoDateTime, widget.event.timezone);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Acara",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.event.imageUrl,
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
                    widget.event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    text:
                        "${widget.event.localDate} @ ${widget.event.localTime} (${widget.event.timezone})",
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.attach_money,
                    text: _formatCurrency(
                      widget.event.minPrice,
                      widget.event.currency,
                    ),
                  ),
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
