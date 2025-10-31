import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/currency_service.dart';
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
  final CurrencyService _currencyService = CurrencyService();

  late bool _isFavorite;
  bool _isConverting = false;
  String? _convertedPriceText;

  @override
  void initState() {
    super.initState();
    _isFavorite = _favoritesService.isFavorite(widget.event);
    print(
      'DEBUG DETAIL: initState - isFavorite: $_isFavorite for event: ${widget.event.name}',
    );
  }

  Future<void> _showConvertedPrice() async {
    setState(() {
      _isConverting = true;
    });

    try {
      final rates = await _currencyService.getRates();
      final from = widget.event.currency;
      const to = 'IDR';

      if (!rates.containsKey(from) || !rates.containsKey(to)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal konversi: kurs tidak tersedia')),
        );
        return;
      }

      final double fromRate = (rates[from] as num).toDouble();
      final double toRate = (rates[to] as num).toDouble();

      double convert(double amount) {
        if (amount <= 0) return 0.0;
        return (amount / fromRate) * toRate;
      }

      final convertedMin = convert(widget.event.minPrice);
      final convertedMax = convert(widget.event.maxPrice);

      final idrFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'IDR ',
        decimalDigits: 2,
      );

      String message;
      if (convertedMin > 0 &&
          convertedMax > 0 &&
          convertedMax != convertedMin) {
        message =
            '${idrFormat.format(convertedMin)} - ${idrFormat.format(convertedMax)}';
      } else if (convertedMin > 0) {
        message = idrFormat.format(convertedMin);
      } else {
        message = 'Harga tidak tersedia';
      }

      if (!mounted) return;
      setState(() {
        _convertedPriceText = message;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal konversi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  String _formatPriceRange(
    double minPrice,
    double maxPrice,
    String currencyCode,
  ) {
    if (minPrice == 0.0 && maxPrice == 0.0) {
      return "Harga tidak tersedia";
    }

    String symbol = currencyCode != 'N/A' ? '$currencyCode ' : '';

    if (maxPrice > 0 && maxPrice != minPrice && minPrice > 0) {
      final minStr = NumberFormat.currency(
        locale: 'en_US',
        symbol: symbol,
        decimalDigits: 2,
      ).format(minPrice);
      final maxStr = NumberFormat.currency(
        locale: 'en_US',
        symbol: symbol,
        decimalDigits: 2,
      ).format(maxPrice);
      return "$minStr - $maxStr";
    }

    final price = minPrice > 0 ? minPrice : maxPrice;
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    ).format(price);
  }

  void _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(widget.event);
        setState(() {
          _isFavorite = false;
        });
        print('DEBUG DETAIL: Removed from favorites');
      } else {
        await _favoritesService.addFavorite(widget.event);
        setState(() {
          _isFavorite = true;
        });
        print('DEBUG DETAIL: Added to favorites');
      }
    } catch (e) {
      print('DEBUG DETAIL: Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
                    text:
                        _convertedPriceText ??
                        _formatPriceRange(
                          widget.event.minPrice,
                          widget.event.maxPrice,
                          widget.event.currency,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_convertedPriceText == null)
                    ElevatedButton.icon(
                      onPressed: _isConverting
                          ? null
                          : () async {
                              await _showConvertedPrice();
                            },
                      icon: const Icon(Icons.currency_exchange),
                      label: Text(
                        _isConverting ? 'Memproses...' : 'Konversi ke IDR',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
