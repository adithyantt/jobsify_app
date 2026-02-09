import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    // 1️⃣ Permission check
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    // 2️⃣ Get GPS
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3️⃣ Reverse geocoding (OpenStreetMap)
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse"
      "?format=json&lat=${position.latitude}&lon=${position.longitude}",
    );

    final response = await http.get(url, headers: {"User-Agent": "JobsifyApp"});

    final data = jsonDecode(response.body);
    final address = data["address"] ?? {};

    return {
      "lat": position.latitude,
      "lng": position.longitude,
      "place":
          address["village"] ??
          address["town"] ??
          address["city"] ??
          address["district"] ??
          "Unknown location",
    };
  }

  static double distanceKm(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    final meters = Geolocator.distanceBetween(
      fromLat,
      fromLng,
      toLat,
      toLng,
    );
    return meters / 1000.0;
  }
}
