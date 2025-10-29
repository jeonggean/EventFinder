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
      if (json['images'] != null && json['images'].isNotEmpty) {
        // Ambil gambar dengan rasio 16_9, jika tidak ada, ambil gambar pertama
        final fallbackImage = json['images'][0]['url'];
        final preferredImage = (json['images'] as List).firstWhere(
          (img) => img['ratio'] == '16_9',
          orElse: () => null,
        );
        return preferredImage?['url'] ?? fallbackImage;
      }
      return 'https://i.imgur.com/gA1q3nJ.png'; // Gambar placeholder
    }

    String getCurrency(Map<String, dynamic> json) {
      if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
        return json['priceRanges'][0]['currency'] ?? 'N/A';
      }
      return 'N/A';
    }

    double getPrice(Map<String, dynamic> json, String key) {
      if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
        return (json['priceRanges'][0][key] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    }

    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      imageUrl: getImageUrl(json),
      localDate: json['dates']?['start']?['localDate'] ?? 'No Date',
      localTime: json['dates']?['start']?['localTime'] ?? 'No Time',
      timezone: json['dates']?['timezone'] ?? 'N/A',
      currency: getCurrency(json),
      minPrice: getPrice(json, 'min'),
      maxPrice: getPrice(json, 'max'),
    );
  }
}
