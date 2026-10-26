import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/hotel.dart';
import 'favorite_service.dart';

class HotelService {
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  List<Hotel> _cachedHotels = [];
  bool _hasLoadedOnce = false;

  List<Hotel> get cachedHotels => List.unmodifiable(_cachedHotels);
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Fetches all hotels from [hotel-controller] (GET /api/v1/hotels)
  /// Also retrieves room types for each hotel to ensure live prices & rooms in the UI.
  Future<List<Hotel>> getHotels({bool forceRefresh = false}) async {
    if (_hasLoadedOnce && !forceRefresh && _cachedHotels.isNotEmpty) {
      return _cachedHotels;
    }

    final url = Uri.parse(ApiConfig.hotels);
    if (kDebugMode) {
      print('[HotelService] Fetching hotels from: $url');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> hotelListJson = decoded is List ? decoded : [];

        // Concurrently fetch room types for each hotel
        final List<Hotel> fetchedHotels = await Future.wait(
          hotelListJson.map((hotelJson) async {
            final hotelMap = hotelJson as Map<String, dynamic>;
            final hotelId = hotelMap['id']?.toString() ?? '';

            List<HotelRoom> roomTypes = [];
            if (hotelId.isNotEmpty) {
              try {
                roomTypes = await getRoomTypes(hotelId);
              } catch (e) {
                if (kDebugMode) {
                  print('[HotelService] Could not fetch room types for hotel $hotelId: $e');
                }
              }
            }

            return Hotel.fromJson(hotelMap, roomTypes: roomTypes);
          }),
        );

        // Sort by id to maintain consistent order
        fetchedHotels.sort((a, b) => (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0));

        // Synchronize live favorites from database
        try {
          await FavoriteService().getFavorites();
          FavoriteService().syncHotels(fetchedHotels);
        } catch (e) {
          if (kDebugMode) {
            print('[HotelService] Could not sync favorites: $e');
          }
        }

        _cachedHotels = fetchedHotels;
        _hasLoadedOnce = true;
        return _cachedHotels;
      } else {
        throw Exception('Failed to load hotels. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HotelService] Error fetching hotels from $url: $e');
      }
      rethrow;
    }
  }

  /// Fetches a single hotel by ID from [hotel-controller] (GET /api/v1/hotels/{id})
  Future<Hotel> getHotelById(String id) async {
    final url = Uri.parse(ApiConfig.hotelById(id));
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> hotelMap = jsonDecode(utf8.decode(response.bodyBytes));
        final rooms = await getRoomTypes(id);
        return Hotel.fromJson(hotelMap, roomTypes: rooms);
      } else {
        throw Exception('Failed to load hotel $id. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HotelService] Error fetching hotel $id: $e');
      }
      final fallback = _cachedHotels.firstWhere(
        (h) => h.id == id,
        orElse: () => throw Exception('Hotel $id not found in cache ($e)'),
      );
      return fallback;
    }
  }

  /// Fetches room types for a hotel (GET /api/v1/room-types/hotel/{hotelId})
  Future<List<HotelRoom>> getRoomTypes(String hotelId) async {
    final url = Uri.parse(ApiConfig.hotelRoomTypes(hotelId));
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          return decoded.map((r) => HotelRoom.fromJson(r as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HotelService] Error loading room types for hotel $hotelId: $e');
      }
    }
    return [];
  }

  /// Create a new hotel (POST /api/v1/hotels)
  Future<Hotel?> createHotel(Map<String, dynamic> data) async {
    final url = Uri.parse(ApiConfig.hotels);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final created = Hotel.fromJson(decoded);
        _cachedHotels.add(created);
        return created;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HotelService] Error creating hotel: $e');
      }
    }
    return null;
  }

  /// Delete a hotel (DELETE /api/v1/hotels/{id})
  Future<bool> deleteHotel(String id) async {
    final url = Uri.parse(ApiConfig.hotelById(id));
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        _cachedHotels.removeWhere((h) => h.id == id);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HotelService] Error deleting hotel $id: $e');
      }
    }
    return false;
  }

  /// Toggle favorite on a hotel model with backend synchronization
  Future<bool> toggleFavorite(Hotel hotel) async {
    return await FavoriteService().toggleFavorite(hotel);
  }
}
