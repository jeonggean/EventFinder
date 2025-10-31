import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      setState(() {});
    });

    _controller.loadFavorites();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit Saya',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.favorites.isEmpty) {
      return Center(
        child: Text(
          'Kamu belum punya acara favorit.',
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _controller.favorites.length,
      itemBuilder: (context, index) {
        final EventModel event = _controller.favorites[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
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
            child: ListTile(
              leading: Image.network(
                event.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
              ),
              title: Text(
                event.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(event.localDate),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      },
    );
  }
}
