class Hotel {
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
  bool isFavorite;

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
    this.isFavorite = false,
  });
}

class HotelAmenity {
  final String name;
  final String iconKey; // maps to a material icon name or specific helper

  const HotelAmenity({
    required this.name,
    required this.iconKey,
  });
}

// Global list of mock hotels for UI representation
final List<Hotel> mockHotels = [
  Hotel(
    id: '1',
    name: 'The Obsidian Pavilion',
    location: 'Svenstorp, Sweden',
    city: 'Svenstorp',
    country: 'Sweden',
    rating: 4.92,
    reviewsCount: 148,
    price: 320.0,
    description:
        'A striking architectural marvel nestled in the Swedish pine forests. Designed with floor-to-ceiling glass and matte-black metal, this private cabin offers an immersive nature experience. Watch the northern lights from your heated outdoor pool or unwind in the wood-fired Finnish sauna.',
    imageUrl: 'https://images.unsplash.com/photo-1508333706533-1ab43ecb1606?auto=format&fit=crop&q=80&w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1508333706533-1ab43ecb1606?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1475855522379-029000961472?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&q=80&w=800',
    ],
    amenities: [
      const HotelAmenity(name: 'Sauna', iconKey: 'spa'),
      const HotelAmenity(name: 'Heated Pool', iconKey: 'pool'),
      const HotelAmenity(name: 'Wifi 6', iconKey: 'wifi'),
      const HotelAmenity(name: 'Fireplace', iconKey: 'fireplace'),
      const HotelAmenity(name: 'Kitchen', iconKey: 'kitchen'),
    ],
    beds: 2,
    baths: 2,
    guests: 4,
    isFavorite: true,
  ),
  Hotel(
    id: '2',
    name: 'Amanpuri Villa',
    location: 'Phuket, Thailand',
    city: 'Phuket',
    country: 'Thailand',
    rating: 4.88,
    reviewsCount: 94,
    price: 450.0,
    description:
        'Overlooking the pristine turquoise waters of the Andaman Sea, Amanpuri offers a sanctuary of peace and tropical elegance. Surrounded by coconut groves, this villa showcases traditional Thai architecture seamlessly blended with ultra-modern luxury and personalized butler services.',
    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80&w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&q=80&w=800',
    ],
    amenities: [
      const HotelAmenity(name: 'Beach Access', iconKey: 'beach_access'),
      const HotelAmenity(name: 'Infinity Pool', iconKey: 'pool'),
      const HotelAmenity(name: 'AC', iconKey: 'ac_unit'),
      const HotelAmenity(name: 'Spa', iconKey: 'spa'),
      const HotelAmenity(name: 'Gym', iconKey: 'fitness_center'),
    ],
    beds: 3,
    baths: 3,
    guests: 6,
  ),
  Hotel(
    id: '3',
    name: 'Kyoto Machiya Residence',
    location: 'Gion, Kyoto, Japan',
    city: 'Kyoto',
    country: 'Japan',
    rating: 4.96,
    reviewsCount: 204,
    price: 280.0,
    description:
        'Live like a local in this meticulously restored 100-year-old traditional townhouse. Situated in the heart of the historic Gion district, it features tatami mats, paper screens, a hidden private Zen garden, and a hinoki cypress wood soaking tub. Perfect for travelers seeking a cultural retreat.',
    imageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&q=80&w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1528164344705-47542687000d?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1490730141103-d89d6e2cca00?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1542044896530-05d85be9b11a?auto=format&fit=crop&q=80&w=800',
    ],
    amenities: [
      const HotelAmenity(name: 'Zen Garden', iconKey: 'yard'),
      const HotelAmenity(name: 'Hinoki Tub', iconKey: 'bathtub'),
      const HotelAmenity(name: 'Teahouse', iconKey: 'coffee_maker'),
      const HotelAmenity(name: 'Wifi', iconKey: 'wifi'),
      const HotelAmenity(name: 'Bicycles', iconKey: 'pedal_bike'),
    ],
    beds: 2,
    baths: 1,
    guests: 3,
  ),
  Hotel(
    id: '4',
    name: 'Sanctuary Cliff House',
    location: 'Santorini, Greece',
    city: 'Santorini',
    country: 'Greece',
    rating: 4.95,
    reviewsCount: 312,
    price: 520.0,
    description:
        'Carved into the volcanic caldera cliffs, this iconic white-washed dome suite delivers breathtaking views of the Aegean Sea sunset. Features a heated cave plunge pool, minimalist Cycladic interiors, and a sun-drenched private terrace that feels suspended in the blue sky.',
    imageUrl: 'https://images.unsplash.com/photo-1570183180671-a34057394de9?auto=format&fit=crop&q=80&w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1570183180671-a34057394de9?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1469796466635-455edd028a14?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&q=80&w=800',
    ],
    amenities: [
      const HotelAmenity(name: 'Cave Pool', iconKey: 'pool'),
      const HotelAmenity(name: 'Sea View', iconKey: 'wb_sunny'),
      const HotelAmenity(name: 'Breakfast', iconKey: 'restaurant'),
      const HotelAmenity(name: 'Terrace', iconKey: 'deck'),
      const HotelAmenity(name: 'Bar', iconKey: 'local_bar'),
    ],
    beds: 1,
    baths: 1,
    guests: 2,
    isFavorite: true,
  ),
  Hotel(
    id: '5',
    name: 'The Loft at NoHo',
    location: 'New York, USA',
    city: 'New York',
    country: 'USA',
    rating: 4.79,
    reviewsCount: 82,
    price: 380.0,
    description:
        'An industrial-chic loft in New York\'s fashionable NoHo neighborhood. Boasting double-height ceilings, exposed brick walls, original hardwood floors, and mid-century modern furnishings. Steps away from the city\'s finest dining, cafes, and contemporary art galleries.',
    imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1512917774-c2c8f000b016?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&q=80&w=800',
    ],
    amenities: [
      const HotelAmenity(name: 'City View', iconKey: 'location_city'),
      const HotelAmenity(name: 'Kitchen', iconKey: 'kitchen'),
      const HotelAmenity(name: 'Workspace', iconKey: 'laptop'),
      const HotelAmenity(name: 'AC', iconKey: 'ac_unit'),
      const HotelAmenity(name: 'Elevator', iconKey: 'elevator'),
    ],
    beds: 1,
    baths: 1.5.toInt(),
    guests: 2,
  ),
];
