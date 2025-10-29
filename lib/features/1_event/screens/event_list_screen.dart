import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = EventController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _controller.changeMode(
        _tabController.index == 0
            ? EventListMode.nearby
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
    if (price == 0.0 && currencyCode == 'N/A') return "Harga tidak tersedia";
    if (price == 0.0) return "Gratis";
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: "$currencyCode ",
      decimalDigits: 2,
    );
    return format.format(price);
  }

  Widget _buildEventList(List<EventModel> events) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage.isNotEmpty && events.isEmpty) {
      String displayError = _controller.errorMessage;
      if (displayError.contains('Izin lokasi ditolak')) {
        displayError =
            'Izin lokasi dibutuhkan untuk menampilkan acara di sekitarmu. Aktifkan di pengaturan HP.';
      } else if (displayError.contains('Layanan lokasi tidak aktif')) {
        displayError =
            'Layanan lokasi (GPS) di HP-mu mati. Aktifkan untuk mencari acara di sekitar.';
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
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 16),
          ),
        ),
      );
    }

    if (events.isEmpty) {
      String message = _controller.currentMode == EventListMode.nearby
          ? 'Tidak ada acara ditemukan di sekitarmu.'
          : 'Tidak ada acara populer ditemukan.';
      if (_searchController.text.isNotEmpty) {
        message =
            'Tidak ada acara ditemukan untuk "${_searchController.text}".';
      }
      return Center(child: Text(message, textAlign: TextAlign.center));
    }

    return ListView.builder(
      key: PageStorageKey(
        _controller.currentMode,
      ), // Kunci agar posisi scroll diingat per tab
      itemCount: events.length,
      itemBuilder: (context, index) {
        final EventModel event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  event.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${event.localDate} @ ${event.localTime}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatCurrency(event.minPrice, event.currency),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EventFinder',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.nunito(),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Di Sekitarmu'),
            Tab(text: 'Populer'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari acara...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _controller.searchEvents('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (String keyword) {
                _controller.searchEvents(keyword);
              },
            ),
          ),
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
    );
  }
}
