import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_rental/services/favorite_service.dart';
import 'package:hotel_rental/services/hotel_service.dart';

void main() {
  test('HotelService fetches real hotels from localhost:8030/api/v1/hotels', () async {
    final service = HotelService();
    final hotels = await service.getHotels(forceRefresh: true);

    expect(hotels.isNotEmpty, true);
    print('Fetched ${hotels.length} hotels from hotel-controller:');
    for (final h in hotels) {
      print(' - ID: ${h.id}, Name: ${h.name}, City: ${h.city}, Price: \$${h.price}, Rooms: ${h.rooms.length}');
      for (final r in h.rooms) {
        print('     Room: ${r.name}, Price: \$${r.price}, Guests: ${r.guests}');
      }
    }

    final rooms2 = await service.getRoomTypes('2');
    print('Direct getRoomTypes("2") length: ${rooms2.length}');
    for (final r in rooms2) {
      print('  Direct Room: ${r.name}, Price: \$${r.price}');
    }

    final firstHotel = hotels.first;
    expect(firstHotel.name.isNotEmpty, true);
    expect(firstHotel.imageUrl.isNotEmpty, true);
  });

  test('FavoriteService connects to /api/v1/favorites endpoint', () async {
    final favService = FavoriteService();
    final initialList = await favService.getFavorites();
    print('Initial favorites count: ${initialList.length}');

    // Test adding favorite for hotel 2
    final newId = await favService.addFavorite(hotelId: 2, userId: 1);
    print('Added favorite ID: $newId');
    expect(newId != null, true);

    // Verify it is in favorites
    final updatedList = await favService.getFavorites();
    expect(updatedList.any((f) => f.hotelId == 2), true);
    print('Updated favorites count: ${updatedList.length}');

    // Test removing favorite
    if (newId != null) {
      final removed = await favService.removeFavorite(newId);
      print('Removed favorite result: $removed');
      expect(removed, true);
    }
  });
}
