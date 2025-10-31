import 'package:eventfinder/core/utils/app_colors.dart';
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
      } else {
        await _favoritesService.addFavorite(widget.event);
        setState(() {
          _isFavorite = true;
        });
      }
    } catch (e) {
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

    final Map<String, String> convertedTimes =
        _timezoneHelper.getConvertedTimes(isoDateTime, widget.event.timezone);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildNavigationButtons(),
          _buildContentSheet(convertedTimes),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Image.network(
        widget.event.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).cardColor,
          child: const Icon(
            Icons.broken_image,
            size: 60,
            color: AppColors.kSecondaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: _isFavorite
                      ? AppColors.kPrimaryColor
                      : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSheet(Map<String, String> convertedTimes) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.name,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: AppColors.kTextColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailItem(
              icon: Icons.calendar_today_outlined,
              title: "Tanggal & Waktu",
              subtitle:
                  "${widget.event.localDate} @ ${widget.event.localTime} (${widget.event.timezone})",
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.attach_money,
              title: "Harga",
              subtitle: _convertedPriceText ??
                  _formatPriceRange(
                    widget.event.minPrice,
                    widget.event.maxPrice,
                    widget.event.currency,
                  ),
            ),
            const SizedBox(height: 20),
            if (_convertedPriceText == null)
              ElevatedButton.icon(
                onPressed: _isConverting ? null : _showConvertedPrice,
                icon: Icon(Icons.currency_exchange, size: 18),
                label: Text(
                  _isConverting ? 'Memproses...' : 'Konversi ke IDR',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            const SizedBox(height: 30),
            Text(
              "Perbandingan Zona Waktu",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.kTextColor,
              ),
            ),
            Divider(height: 20, color: Theme.of(context).cardColor),
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
    );
  }

  Widget _buildDetailItem(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).cardColor,
          child: Icon(icon, color: AppColors.kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.kSecondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimezoneRow(String zoneName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            zoneName,
            style:
                TextStyle(fontSize: 16, color: AppColors.kSecondaryTextColor),
          ),
          Text(
            time,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor),
          ),
        ],
      ),
    );
  }
}