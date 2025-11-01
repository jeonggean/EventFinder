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

  late Future<bool> _isFavoriteFuture;

  bool _isConvertingPrice = false;
  String? _convertedPriceText;
  late List<String> _targetCurrencies;
  late String _selectedTargetCurrency;

  final Map<String, String> _targetTimezones = {
    'WIB (Jakarta)': 'Asia/Jakarta',
    'WITA (Makassar)': 'Asia/Makassar',
    'WIT (Jayapura)': 'Asia/Jayapura',
    'London (GMT)': 'Europe/London',
    'Tokyo (JST)': 'Asia/Tokyo',
    'New York (ET)': 'America/New_York',
  };
  late String _selectedTimezoneKey;
  Map<String, String>? _convertedTimeMap;

  @override
  void initState() {
    super.initState();
    _isFavoriteFuture = _favoritesService.isFavorite(widget.event);

    _targetCurrencies = ['IDR', 'USD', 'EUR', 'JPY'];
    if (widget.event.currency != 'N/A' &&
        !_targetCurrencies.contains(widget.event.currency)) {
      _targetCurrencies.add(widget.event.currency);
    }
    _selectedTargetCurrency = _targetCurrencies.first;

    _selectedTimezoneKey = _targetTimezones.keys.first;
  }

  Future<void> _showConvertedPrice(String targetCurrency) async {
    setState(() {
      _isConvertingPrice = true;
    });

    try {
      final rates = await _currencyService.getRates();
      final from = widget.event.currency;
      final to = targetCurrency;

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

      final Map<String, NumberFormat> formatters = {
        'IDR': NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'IDR ',
          decimalDigits: 2,
        ),
        'USD': NumberFormat.currency(
          locale: 'en_US',
          symbol: 'USD ',
          decimalDigits: 2,
        ),
        'EUR': NumberFormat.currency(
          locale: 'de_DE',
          symbol: 'EUR ',
          decimalDigits: 2,
        ),
        'JPY': NumberFormat.currency(
          locale: 'ja_JP',
          symbol: 'JPY ',
          decimalDigits: 0,
        ),
      };

      final format =
          formatters[targetCurrency] ??
          NumberFormat.currency(
            locale: 'en_US',
            symbol: '$targetCurrency ',
            decimalDigits: 2,
          );

      String message;
      if (convertedMin > 0 &&
          convertedMax > 0 &&
          convertedMax != convertedMin) {
        message =
            '${format.format(convertedMin)} - ${format.format(convertedMax)}';
      } else if (convertedMin > 0) {
        message = format.format(convertedMin);
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
          _isConvertingPrice = false;
        });
      }
    }
  }

  void _showConvertedTime() {
    final String targetTimezoneId = _targetTimezones[_selectedTimezoneKey]!;
    final String isoDateTime = _timezoneHelper.getIsoDateTime(
      widget.event.localDate,
      widget.event.localTime,
    );

    final Map<String, String> convertedTime = _timezoneHelper
        .getConvertedTimeForZone(
          isoDateTime,
          widget.event.timezone,
          targetTimezoneId,
        );

    setState(() {
      _convertedTimeMap = convertedTime;
    });
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

  String _formatDate(String dateString) {
    if (dateString == 'TBA') return 'Tanggal Belum Diumumkan';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _toggleFavorite(bool isCurrentlyFavorite) async {
    try {
      if (isCurrentlyFavorite) {
        await _favoritesService.removeFavorite(widget.event);
      } else {
        await _favoritesService.addFavorite(widget.event);
      }

      if (mounted) {
        setState(() {
          _isFavoriteFuture = _favoritesService.isFavorite(widget.event);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildNavigationButtons(),
          _buildContentSheet(),
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
            FutureBuilder<bool>(
              future: _isFavoriteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                final bool isFavorite = snapshot.data ?? false;

                return CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite
                          ? AppColors.kPrimaryColor
                          : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(isFavorite),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSheet() {
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
              title: "Tanggal",
              subtitle: _formatDate(widget.event.localDate),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.access_time_outlined,
              title: "Waktu",
              subtitle: widget.event.localTime,
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.location_on_outlined,
              title: "Lokasi",
              subtitle:
                  "${widget.event.venueName}, ${widget.event.venueCountry}",
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.attach_money,
              title: "Harga",
              subtitle:
                  _convertedPriceText ??
                  _formatPriceRange(
                    widget.event.minPrice,
                    widget.event.maxPrice,
                    widget.event.currency,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              "Konversikan Harga ke Mata Uang Lain",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.kTextColor,
              ),
            ),
            Divider(height: 20, color: Theme.of(context).cardColor),
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedTargetCurrency,
                    underline: Container(),
                    items: _targetCurrencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(
                          currency,
                          style: TextStyle(color: AppColors.kTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTargetCurrency = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConvertingPrice
                        ? null
                        : () async {
                            await _showConvertedPrice(_selectedTargetCurrency);
                          },
                    child: Text(_isConvertingPrice ? '...' : 'Konversi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "Lihat Jadwal di Zona Waktu Lain",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.kTextColor,
              ),
            ),
            Divider(height: 20, color: Theme.of(context).cardColor),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedTimezoneKey,
                    underline: Container(),
                    items: _targetTimezones.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(
                          key,
                          style: TextStyle(color: AppColors.kTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimezoneKey = newValue;
                          _convertedTimeMap = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showConvertedTime,
                    child: Text('Konversi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_convertedTimeMap != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    title: "Tanggal (Konversi)",
                    subtitle: _convertedTimeMap!['date'] ?? 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.access_time_outlined,
                    title: "Waktu (Konversi)",
                    subtitle: _convertedTimeMap!['time'] ?? 'N/A',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
}
