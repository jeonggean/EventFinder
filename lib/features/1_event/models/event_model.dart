import 'dart:math';

class EventModel {
  final String id;
  final String name;
  final String imageUrl;
  final String localDate;
  final String localTime;
  final String timezone;
  final String currency;
  final double minPrice;
  final double maxPrice;

  EventModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.localDate,
    required this.localTime,
    required this.timezone,
    required this.currency,
    required this.minPrice,
    required this.maxPrice,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String getImageUrl(Map<String, dynamic> json) {
      if (json.containsKey('imageUrl')) {
        return json['imageUrl'] ?? 'https://i.imgur.com/gA1q3nJ.png';
      }
      if (json['images'] != null && json['images'].isNotEmpty) {
        final fallbackImage = json['images'][0]['url'];
        final preferredImage = (json['images'] as List).firstWhere(
          (img) => img['ratio'] == '16_9',
          orElse: () => null,
        );
        return preferredImage?['url'] ?? fallbackImage;
      }
      return 'https://i.imgur.com/gA1q3nJ.png';
    }

    // Deterministic hash function untuk generate random seed dari event ID
    int _hashString(String str) {
      int hash = 5381;
      for (int i = 0; i < str.length; i++) {
        hash = ((hash << 5) + hash) + str.codeUnitAt(i);
      }
      return hash.abs();
    }

    // Get currency, minPrice, maxPrice with fallback to deterministic pseudo-random
    final String eventId = json['id'] ?? '';
    String currency;
    double minPrice;
    double maxPrice;

    // Check if priceRanges exists
    if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
      final priceRange = json['priceRanges'][0];
      currency = priceRange['currency'] ?? 'USD';
      minPrice = (priceRange['min'] as num?)?.toDouble() ?? 0.0;
      maxPrice = (priceRange['max'] as num?)?.toDouble() ?? 0.0;
    } else if (json.containsKey('currency') &&
        json.containsKey('minPrice') &&
        json.containsKey('maxPrice')) {
      // If already persisted (from Hive)
      currency = json['currency'] ?? 'USD';
      minPrice = (json['minPrice'] as num?)?.toDouble() ?? 0.0;
      maxPrice = (json['maxPrice'] as num?)?.toDouble() ?? 0.0;
    } else {
      // Generate deterministic pseudo-random price based on event ID
      currency = 'USD';
      final seed = _hashString(eventId);
      final random = Random(seed);

      // Generate min price between $15 - $50
      minPrice = 15.0 + (random.nextDouble() * 35.0);

      // Generate max price between minPrice + $20 and minPrice + $80
      maxPrice = minPrice + 20.0 + (random.nextDouble() * 60.0);

      // Round to 2 decimal places
      minPrice = double.parse(minPrice.toStringAsFixed(2));
      maxPrice = double.parse(maxPrice.toStringAsFixed(2));
    }

    return EventModel(
      id: eventId,
      name: json['name'] ?? 'No Name',
      imageUrl: json['imageUrl'] ?? getImageUrl(json),
      localDate:
          json['localDate'] ??
          json['dates']?['start']?['localDate'] ??
          'No Date',
      localTime:
          json['localTime'] ??
          json['dates']?['start']?['localTime'] ??
          'No Time',
      timezone: json['timezone'] ?? json['dates']?['timezone'] ?? 'N/A',
      currency: currency,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localDate': localDate,
      'localTime': localTime,
      'timezone': timezone,
      'currency': currency,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }
}
