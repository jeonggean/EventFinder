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

    String getCurrency(Map<String, dynamic> json) {
       if (json.containsKey('currency')) {
         return json['currency'] ?? 'N/A';
       }
      if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
        return json['priceRanges'][0]['currency'] ?? 'N/A';
      }
      return 'N/A';
    }

    double getPrice(Map<String, dynamic> json, String key) {
      if (json.containsKey(key)) {
         return (json[key] as num?)?.toDouble() ?? 0.0;
      }
      if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
        return (json['priceRanges'][0][key] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    }

     String getDate(Map<String, dynamic> json) {
       if (json.containsKey('localDate')) {
         return json['localDate'] ?? 'No Date';
       }
       return json['dates']?['start']?['localDate'] ?? 'No Date';
     }

     String getTime(Map<String, dynamic> json) {
        if (json.containsKey('localTime')) {
         return json['localTime'] ?? 'No Time';
       }
       return json['dates']?['start']?['localTime'] ?? 'No Time';
     }

     String getTimezone(Map<String, dynamic> json) {
       if (json.containsKey('timezone')) {
         return json['timezone'] ?? 'N/A';
       }
       return json['dates']?['timezone'] ?? 'N/A';
     }


    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      imageUrl: getImageUrl(json),
      localDate: getDate(json),
      localTime: getTime(json),
      timezone: getTimezone(json),
      currency: getCurrency(json),
      minPrice: getPrice(json, 'minPrice'), 
      maxPrice: getPrice(json, 'maxPrice'),
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