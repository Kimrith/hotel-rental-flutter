import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/hotel.dart';

class FavoriteItem {
  final int id;
  final int userId;
  final int hotelId;
  final int? roomId;
  final DateTime? createdAt;

  const FavoriteItem({
    required this.id,
    required this.userId,
    required this.hotelId,
    this.roomId,
    this.createdAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      hotelId: (json['hotelId'] as num?)?.toInt() ?? 0,
      roomId: (json['roomId'] as num?)?.toInt(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'hotelId': hotelId,
        'roomId': roomId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  /// Default user ID for testing / single-user session
  int defaultUserId = 1;

  /// Cache: hotelId -> favorite record ID in database
  final Map<int, int> _favoriteIdByHotelId = {};

  Map<int, int> get favoriteIdByHotelId => Map.unmodifiable(_favoriteIdByHotelId);

  bool isHotelFavorited(int hotelId) => _favoriteIdByHotelId.containsKey(hotelId);

  /// Fetch all favorites from backend: GET /api/v1/favorites
  Future<List<FavoriteItem>> getFavorites() async {
    final url = Uri.parse(ApiConfig.favorites);
    if (kDebugMode) {
      print('[FavoriteService] GET $url');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          final items = decoded
              .map((f) => FavoriteItem.fromJson(f as Map<String, dynamic>))
              .toList();

          _favoriteIdByHotelId.clear();
          for (final item in items) {
            if (item.hotelId > 0 && item.id > 0) {
              _favoriteIdByHotelId[item.hotelId] = item.id;
            }
          }
          return items;
        }
      } else {
        if (kDebugMode) {
          print('[FavoriteService] GET failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FavoriteService] Error getting favorites: $e');
      }
    }
    return [];
  }

  /// Add a hotel to favorites: POST /api/v1/favorites
  Future<int?> addFavorite({required int hotelId, int? userId, int? roomId}) async {
    final uid = userId ?? defaultUserId;
    final url = Uri.parse(ApiConfig.favorites);

    final payload = {
      'userId': uid,
      'hotelId': hotelId,
      ...? (roomId != null ? {'roomId': roomId} : null),
    };

    if (kDebugMode) {
      print('[FavoriteService] POST $url body: $payload');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final favId = (decoded['id'] as num?)?.toInt();
        if (favId != null && favId > 0) {
          _favoriteIdByHotelId[hotelId] = favId;
        }
        return favId;
      } else {
        if (kDebugMode) {
          print('[FavoriteService] POST failed with status: ${response.statusCode} body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FavoriteService] Error adding favorite: $e');
      }
    }
    return null;
  }

  /// Remove a favorite by ID: DELETE /api/v1/favorites/{id}
  Future<bool> removeFavorite(int favoriteId) async {
    final url = Uri.parse(ApiConfig.favoriteById(favoriteId));
    if (kDebugMode) {
      print('[FavoriteService] DELETE $url');
    }

    try {
      final response = await http.delete(
        url,
        headers: {'Accept': '*/*'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _favoriteIdByHotelId.removeWhere((k, v) => v == favoriteId);
        return true;
      } else {
        if (kDebugMode) {
          print('[FavoriteService] DELETE failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FavoriteService] Error removing favorite: $e');
      }
    }
    return false;
  }

  /// Toggle favorite on a hotel model with backend synchronization
  Future<bool> toggleFavorite(Hotel hotel, {int? userId}) async {
    final int hotelId = int.tryParse(hotel.id) ?? 0;
    if (hotelId <= 0) return false;

    // Check if currently favorited
    int? favId = hotel.favoriteId ?? _favoriteIdByHotelId[hotelId];

    if (hotel.isFavorite && favId != null) {
      // Optimistic update
      hotel.isFavorite = false;
      hotel.favoriteId = null;

      final success = await removeFavorite(favId);
      if (!success) {
        // Rollback on failure
        hotel.isFavorite = true;
        hotel.favoriteId = favId;
        _favoriteIdByHotelId[hotelId] = favId;
        return false;
      }
      return true;
    } else {
      // Optimistic update
      hotel.isFavorite = true;

      final newFavId = await addFavorite(hotelId: hotelId, userId: userId);
      if (newFavId != null) {
        hotel.favoriteId = newFavId;
        _favoriteIdByHotelId[hotelId] = newFavId;
        return true;
      } else {
        // Rollback on failure
        hotel.isFavorite = false;
        hotel.favoriteId = null;
        return false;
      }
    }
  }

  /// Synchronize a list of hotels with live backend favorites state
  void syncHotels(List<Hotel> hotels) {
    for (final hotel in hotels) {
      final int hotelId = int.tryParse(hotel.id) ?? 0;
      if (_favoriteIdByHotelId.containsKey(hotelId)) {
        hotel.isFavorite = true;
        hotel.favoriteId = _favoriteIdByHotelId[hotelId];
      } else {
        hotel.isFavorite = false;
        hotel.favoriteId = null;
      }
    }
  }
}
