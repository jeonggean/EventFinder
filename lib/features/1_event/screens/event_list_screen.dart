import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/location_service.dart';
import '../../2_auth/services/auth_service.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late final EventController _controller;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  String? _currentLocationName;
  bool _isLocationLoading = true;
  late Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _controller = EventController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _fetchLocationName();
    _usernameFuture = _authService.getCurrentUsername();
  }

  Future<void> _fetchLocationName() async {
    setState(() {
      _isLocationLoading = true;
    });
    try {
      final cityName = await _locationService.getCityName();
      if (mounted) {
        setState(() {
          _currentLocationName = cityName ?? "Lokasi Tidak Ditemukan";
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationName = "Gagal Mendeteksi Lokasi";
          _isLocationLoading = false;
        });
      }
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _controller.changeMode(
        _tabController.index == 0
            ? EventListMode.regional
            : EventListMode.popular,
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _controller.dispose();
    _searchController.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventList(_controller.eventsToShow),
                  _buildEventList(_controller.eventsToShow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String?>(
                    future: _usernameFuture,
                    builder: (context, snapshot) {
                      final username = snapshot.data ?? 'User';
                      return Text(
                        'Halo, $username!',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Temukan acara favoritmu',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.kSecondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: AppColors.kSecondaryTextColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Lokasi Anda: ",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.kSecondaryTextColor,
                ),
              ),
              _isLocationLoading
                  ? Text(
                      'Mencari...',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kTextColor,
                      ),
                    )
                  : Flexible(
                      child: Text(
                        _currentLocationName ?? 'Tidak Ditemukan',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.kPrimaryColor),
            decoration: InputDecoration(
              hintText: 'Cari acara, konser...',
              hintStyle:
                  TextStyle(color: AppColors.kPrimaryColor.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search,
                  color: AppColors.kPrimaryColor.withOpacity(0.7)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: AppColors.kPrimaryColor.withOpacity(0.7)),
                      onPressed: () {
                        _searchController.clear();
                        _controller.searchEvents('');
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.tune,
                          color: AppColors.kPrimaryColor.withOpacity(0.7)),
                      onPressed: () {},
                    ),
              filled: true,
              fillColor: AppColors.kPrimaryColor.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: (String keyword) {
              _controller.searchEvents(keyword);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.nunito(),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.kSecondaryTextColor,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.kPrimaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(15),
        tabs: const [
          Tab(text: 'Regional (LBS)'),
          Tab(text: 'Populer'),
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (_controller.isLoading) {
      return Center(
          child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary));
    }

    if (_controller.errorMessage.isNotEmpty && events.isEmpty) {
      String displayError = _controller.errorMessage;
      if (displayError.contains('lokasi')) {
        displayError =
            'Gagal mendapatkan lokasimu. Aktifkan GPS dan izin lokasi.';
      } else if (displayError.contains('Gagal memuat data event')) {
        displayError =
            'Gagal mengambil data dari server. Cek koneksi internetmu.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            displayError,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
      );
    }

    if (events.isEmpty) {
      String message = _controller.currentMode == EventListMode.regional
          ? 'Tidak ada acara ditemukan di sekitarmu (radius 2500km).'
          : 'Tidak ada acara populer ditemukan.';
      if (_searchController.text.isNotEmpty) {
        message =
            'Tidak ada acara ditemukan untuk "${_searchController.text}".';
      }
      return Center(
          child: Text(message,
              style:
                  TextStyle(color: AppColors.kSecondaryTextColor, fontSize: 16),
              textAlign: TextAlign.center));
    }

    return ListView.separated(
      key: PageStorageKey(_controller.currentMode),
      padding: const EdgeInsets.all(24.0),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final EventModel event = events[index];
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
        );
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