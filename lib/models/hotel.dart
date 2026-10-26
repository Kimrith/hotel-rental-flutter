class Hotel {
  static const String defaultAssetImage = 'assets/images/defualt_img.png';

  final String id;
  final String name;
  final String location;
  final String city;
  final String country;
  final double rating;
  final int reviewsCount;
  final double price;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final List<HotelAmenity> amenities;
  final int beds;
  final int baths;
  final int guests;
  final List<HotelRoom> rooms;
  bool isFavorite;
  int? favoriteId;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.country,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.amenities,
    required this.beds,
    required this.baths,
    required this.guests,
    required this.rooms,
    this.isFavorite = false,
    this.favoriteId,
  });

  Hotel copyWith({
    String? id,
    String? name,
    String? location,
    String? city,
    String? country,
    double? rating,
    int? reviewsCount,
    double? price,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    List<HotelAmenity>? amenities,
    int? beds,
    int? baths,
    int? guests,
    List<HotelRoom>? rooms,
    bool? isFavorite,
    int? favoriteId,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      city: city ?? this.city,
      country: country ?? this.country,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteId: favoriteId ?? this.favoriteId,
    );
  }

  /// Factory constructor to parse HotelResponseDto from hotel-controller
  factory Hotel.fromJson(Map<String, dynamic> json, {List<HotelRoom>? roomTypes}) {
    final rawId = (json['id'] ?? '').toString();
    final name = (json['name'] ?? 'Luxury Hotel').toString();
    final city = (json['city'] ?? '').toString();
    final address = (json['address'] ?? '').toString();
    final country = (json['country'] ?? 'Cambodia').toString();
    final description = (json['description'] ?? 'An exclusive luxury stay experience with world-class hospitality and modern comforts.').toString();

    // Parse images from backend HotelImageResponseDto or provide curated fallbacks
    List<String> parsedImageUrls = [];
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      for (final img in (json['images'] as List)) {
        if (img is Map && img['imageUrl'] != null && img['imageUrl'].toString().isNotEmpty) {
          parsedImageUrls.add(img['imageUrl'].toString());
        } else if (img is String && img.isNotEmpty) {
          parsedImageUrls.add(img);
        }
      }
    }

    if (parsedImageUrls.isEmpty) {
      parsedImageUrls = _getDefaultImages(rawId, name, city);
    }

    final mainImage = parsedImageUrls.isNotEmpty
        ? parsedImageUrls.first
        : defaultAssetImage;

    // Parse rooms from API
    List<HotelRoom> resolvedRooms = roomTypes ?? [];
    if (resolvedRooms.isEmpty && json['rooms'] is List && (json['rooms'] as List).isNotEmpty) {
      resolvedRooms = (json['rooms'] as List)
          .map((r) => HotelRoom.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    if (resolvedRooms.isEmpty) {
      resolvedRooms = [
        HotelRoom(
          name: 'Standard Room - $name',
          price: (json['price'] as num?)?.toDouble() ?? 80.0,
          beds: 1,
          baths: 1,
          guests: 2,
          imageUrl: defaultAssetImage,
          imageUrls: const [defaultAssetImage],
          type: 'Normal',
          amenities: const ['Wifi', 'Air Conditioning'],
        ),
      ];
    }

    // Determine price dynamically from rooms
    double resolvedPrice = 80.0;
    if (json['price'] != null) {
      resolvedPrice = (json['price'] as num).toDouble();
    } else if (resolvedRooms.isNotEmpty) {
      resolvedPrice = resolvedRooms.map((r) => r.price).reduce((a, b) => a < b ? a : b);
    }

    // Determine specs dynamically from rooms
    int resolvedGuests = 2;
    int resolvedBeds = 1;
    int resolvedBaths = 1;

    if (resolvedRooms.isNotEmpty) {
      resolvedGuests = resolvedRooms.map((r) => r.guests).reduce((a, b) => a > b ? a : b);
      resolvedBeds = resolvedRooms.map((r) => r.beds).reduce((a, b) => a > b ? a : b);
      resolvedBaths = resolvedRooms.map((r) => r.baths).reduce((a, b) => a > b ? a : b);
    } else if (json['guests'] != null) {
      resolvedGuests = (json['guests'] as num).toInt();
    }

    // Extract dynamic amenities from room keywords and description
    final amenities = _extractAmenities(resolvedRooms, description);

    final locationStr = address.isNotEmpty
        ? (city.isNotEmpty ? '$address, $city' : address)
        : (city.isNotEmpty ? '$city, $country' : country);

    return Hotel(
      id: rawId,
      name: name,
      location: locationStr,
      city: city.isNotEmpty ? city : 'Phnom Penh',
      country: country,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : (4.80 + ((int.tryParse(rawId) ?? 1) % 5) * 0.04),
      reviewsCount: json['reviewsCount'] != null ? (json['reviewsCount'] as num).toInt() : (120 + ((int.tryParse(rawId) ?? 1) * 37) % 150),
      price: resolvedPrice,
      description: description,
      imageUrl: mainImage,
      imageUrls: parsedImageUrls,
      amenities: amenities,
      beds: json['beds'] != null ? (json['beds'] as num).toInt() : resolvedBeds,
      baths: json['baths'] != null ? (json['baths'] as num).toInt() : resolvedBaths,
      guests: json['guests'] != null ? (json['guests'] as num).toInt() : resolvedGuests,
      rooms: resolvedRooms,
      isFavorite: json['isFavorite'] == true,
      favoriteId: (json['favoriteId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'city': city,
      'country': country,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'beds': beds,
      'baths': baths,
      'guests': guests,
      'isFavorite': isFavorite,
      'favoriteId': favoriteId,
    };
  }

  static List<String> _getDefaultImages(String id, String name, String city) {
    return [defaultAssetImage];
  }

  static List<HotelAmenity> _extractAmenities(List<HotelRoom> rooms, String description) {
    final Map<String, HotelAmenity> detected = {};
    final fullText = '${rooms.map((r) => '${r.name} ${r.amenities.join(' ')}').join(' ')} $description'.toLowerCase();

    void add(String key, String name, String iconKey) {
      detected[name] = HotelAmenity(name: name, iconKey: iconKey);
    }

    if (fullText.contains('wifi') || fullText.contains('internet')) {
      add('wifi', 'High Speed Wifi', 'wifi');
    }
    if (fullText.contains('pool') || fullText.contains('plunge')) {
      add('pool', 'Swimming Pool', 'pool');
    }
    if (fullText.contains('beach') || fullText.contains('ocean')) {
      add('beach', 'Beach Access', 'beach_access');
    }
    if (fullText.contains('spa') || fullText.contains('jacuzzi') || fullText.contains('bath')) {
      add('spa', 'Spa & Wellness', 'spa');
    }
    if (fullText.contains('balcony') || fullText.contains('patio') || fullText.contains('terrace')) {
      add('balcony', 'Private Balcony', 'deck');
    }
    if (fullText.contains('kitchen') || fullText.contains('kitchenette')) {
      add('kitchen', 'Kitchenette', 'kitchen');
    }
    if (fullText.contains('breakfast') || fullText.contains('dining') || fullText.contains('restaurant')) {
      add('restaurant', 'Restaurant & Dining', 'restaurant');
    }
    if (fullText.contains('ac') || fullText.contains('air conditioning')) {
      add('ac', 'AC Unit', 'ac_unit');
    }
    if (fullText.contains('garden') || fullText.contains('flora')) {
      add('garden', 'Tropical Garden', 'yard');
    }
    if (fullText.contains('workspace') || fullText.contains('desk')) {
      add('workspace', 'Dedicated Workspace', 'laptop');
    }

    if (detected.isEmpty) {
      return const [
        HotelAmenity(name: 'Wifi 6', iconKey: 'wifi'),
        HotelAmenity(name: 'AC Unit', iconKey: 'ac_unit'),
        HotelAmenity(name: 'Room Service', iconKey: 'restaurant'),
      ];
    }

    return detected.values.toList();
  }
}

class HotelAmenity {
  final String name;
  final String iconKey; // maps to a material icon name or specific helper

  const HotelAmenity({
    required this.name,
    required this.iconKey,
  });

  factory HotelAmenity.fromJson(Map<String, dynamic> json) {
    return HotelAmenity(
      name: json['name']?.toString() ?? 'Amenity',
      iconKey: json['iconKey']?.toString() ?? 'check',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'iconKey': iconKey,
  };
}

class HotelRoom {
  final int? id;
  final String name;
  final double price;
  final int beds;
  final int baths;
  final int guests;
  final String imageUrl;
  final List<String> imageUrls;
  final String type;
  final List<String> amenities;

  const HotelRoom({
    this.id,
    required this.name,
    required this.price,
    required this.beds,
    required this.baths,
    required this.guests,
    required this.imageUrl,
    required this.imageUrls,
    required this.type,
    required this.amenities,
  });

  /// Factory constructor to parse RoomTypeResponseDto from /api/v1/room-types
  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    final name = json['name']?.toString() ?? 'Comfort Suite';
    final price = (json['basePrice'] ?? json['price'] ?? 120.0).toDouble();
    final guests = (json['maxGuests'] ?? json['guests'] ?? 2).toInt();
    final beds = (json['beds'] ?? (guests > 2 ? 2 : 1)).toInt();
    final baths = (json['baths'] ?? 1).toInt();
    
    // Parse keywords or amenities
    List<String> amenitiesList = [];
    if (json['searchKeywords'] != null && json['searchKeywords'].toString().isNotEmpty) {
      amenitiesList = json['searchKeywords'].toString().split(',').map((s) => s.trim()).toList();
    } else if (json['amenities'] is List) {
      amenitiesList = (json['amenities'] as List).map((e) => e.toString()).toList();
    }
    if (amenitiesList.isEmpty) {
      amenitiesList = ['Wifi', 'Air Conditioning', 'King Bed'];
    }

    // Determine type
    final type = json['type']?.toString() ?? (price >= 180.0 || name.toLowerCase().contains('villa') || name.toLowerCase().contains('suite') ? 'VIP' : 'Normal');

    final fallbackUrl = Hotel.defaultAssetImage;

    final mainImage = json['imageUrl']?.toString() ?? fallbackUrl;
    final List<String> images = (json['imageUrls'] is List && (json['imageUrls'] as List).isNotEmpty)
        ? (json['imageUrls'] as List).map((e) => e.toString()).toList()
        : [mainImage];

    return HotelRoom(
      id: id,
      name: name,
      price: price,
      beds: beds,
      baths: baths,
      guests: guests,
      imageUrl: mainImage,
      imageUrls: images,
      type: type,
      amenities: amenitiesList,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'price': price,
    'beds': beds,
    'baths': baths,
    'guests': guests,
    'imageUrl': imageUrl,
    'imageUrls': imageUrls,
    'type': type,
    'amenities': amenities,
  };
}
