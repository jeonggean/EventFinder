import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.loadFavorites();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double price, String currencyCode) {
    if (price == 0.0 && currencyCode == 'N/A') return "N/A";
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit Saya',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return Center(
          child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary));
    }

    if (_controller.favorites.isEmpty) {
      return Center(
        child: Text(
          'Kamu belum punya acara favorit.',
          style: GoogleFonts.nunito(
              fontSize: 16, color: AppColors.kSecondaryTextColor),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: _controller.favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final EventModel event = _controller.favorites[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        ).then((_) {
          _controller.loadFavorites();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                event.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  width: 80,
                  color: AppColors.kBackgroundColor,
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: AppColors.kSecondaryTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.kTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: AppColors.kSecondaryTextColor),
                      const SizedBox(width: 6),
                      Text(
                        "${event.localDate} @ ${event.localTime}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 14, color: AppColors.kSecondaryTextColor),
                      const SizedBox(width: 6),
                      Text(
                        _formatCurrency(event.minPrice, event.currency),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}