import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // 1️⃣ Permission check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          "lat": 0.0,
          "lng": 0.0,
          "place": "Location services disabled - Enable GPS",
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            "lat": 0.0,
            "lng": 0.0,
            "place": "Location permission required",
          };
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return {
          "lat": 0.0,
          "lng": 0.0,
          "place": "Location permissions permanently denied",
        };
      }

      // 2️⃣ Get GPS with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
        timeLimit: const Duration(seconds: 20),
      );

      // 3️⃣ Reverse geocoding with timeout & fallback
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?format=json&lat=${position.latitude}&lon=${position.longitude}",
      );

      final response = await http
          .get(url, headers: {"User-Agent": "JobsifyApp/1.0"})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response("timeout", 408),
          );

      String place = "Your location";

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final address = data["address"] as Map<String, dynamic>? ?? {};
          place =
              address["village"]?.toString() ??
              address["town"]?.toString() ??
              address["city"]?.toString() ??
              address["district"]?.toString() ??
              address["state"]?.toString() ??
              address["county"]?.toString() ??
              address["suburb"]?.toString() ??
              "Nearby area";
        } catch (e) {
          developer.log("Geocode parse error: $e");
        }
      } else {
        developer.log("Geocode HTTP ${response.statusCode}: ${response.body}");
      }

      return {
        "lat": position.latitude,
        "lng": position.longitude,
        "place": place,
      };
    } catch (e) {
      developer.log("getCurrentLocation error: $e");
      return {
        "lat": 0.0,
        "lng": 0.0,
        "place": "Unable to get location: Enable GPS & permissions",
      };
    }
  }

  static Future<List<Map<String, String>>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?format=jsonv2"
      "&limit=8"
      "&addressdetails=1"
      "&q=${Uri.encodeQueryComponent(trimmedQuery)}",
    );

    final response = await http
        .get(url, headers: {"User-Agent": "JobsifyApp"})
        .timeout(const Duration(seconds: 15));

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      final address = (map["address"] as Map<String, dynamic>?) ?? {};
      final place =
          address["city"]?.toString() ??
          address["town"]?.toString() ??
          address["village"]?.toString() ??
          address["county"]?.toString() ??
          address["state_district"]?.toString() ??
          map["name"]?.toString() ??
          map["display_name"]?.toString() ??
          trimmedQuery;
      final displayName = map["display_name"]?.toString() ?? place;

      return {"place": place, "display_name": displayName};
    }).toList();
  }

  static double distanceKm(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000.0;
  }
}
