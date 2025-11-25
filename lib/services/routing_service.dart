import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  /// Fetches a route from OpenRouteService between [start] and [end].
  /// Returns an ordered list of LatLng route points.
  static Future<List<LatLng>> fetchRoute({
    required LatLng start,
    required LatLng end,
    required String orsApiKey,
    String profile = 'driving-car',
  }) async {
    final uri = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/$profile/geojson',
    );

    final body = jsonEncode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });

    final res = await http.post(
      uri,
      headers: {'Authorization': orsApiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception(
        'OpenRouteService error ${res.statusCode}: ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}',
      );
    }

    final data = jsonDecode(res.body);

    // Prefer GeoJSON FeatureCollection structure when using /geojson endpoint
    if (data is Map &&
        data['features'] is List &&
        (data['features'] as List).isNotEmpty) {
      final first = (data['features'] as List).first;
      final geom = first['geometry'];
      if (geom is Map && geom['coordinates'] is List) {
        final rawCoords = geom['coordinates'] as List;
        final points = rawCoords
            .map<LatLng>((e) {
              if (e is List && e.length >= 2 && e[0] is num && e[1] is num) {
                final lon = (e[0] as num).toDouble();
                final lat = (e[1] as num).toDouble();
                return LatLng(lat, lon);
              }
              throw Exception('Invalid coordinate pair in GeoJSON feature');
            })
            .toList(growable: false);
        if (_arePointsValid(points)) return points;
      }
      throw Exception('Invalid GeoJSON structure from OpenRouteService');
    }

    // Fallback to classic JSON structure with routes list
    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      return [];
    }
    final geometry = routes[0]['geometry'];

    // Handle both GeoJSON object and encoded polyline string defensively
    if (geometry is Map<String, dynamic>) {
      final rawCoords = geometry['coordinates'];
      if (rawCoords is List) {
        final points = rawCoords
            .map<LatLng>((e) {
              // Expect each e like [lon, lat]
              if (e is List && e.length >= 2 && e[0] is num && e[1] is num) {
                final lon = (e[0] as num).toDouble();
                final lat = (e[1] as num).toDouble();
                return LatLng(lat, lon);
              }
              throw Exception('Invalid coordinate pair in geometry');
            })
            .toList(growable: false);
        if (_arePointsValid(points)) return points;
        throw Exception('Received invalid GeoJSON coordinates');
      }
    } else if (geometry is String) {
      // Some responses may return encoded polyline or even JSON string
      final trimmed = geometry.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final obj = jsonDecode(trimmed);
          if (obj is Map && obj['coordinates'] is List) {
            final rawCoords = obj['coordinates'] as List;
            final points = rawCoords
                .map<LatLng>((e) {
                  if (e is List &&
                      e.length >= 2 &&
                      e[0] is num &&
                      e[1] is num) {
                    final lon = (e[0] as num).toDouble();
                    final lat = (e[1] as num).toDouble();
                    return LatLng(lat, lon);
                  }
                  throw Exception('Invalid coordinate pair in geometry string');
                })
                .toList(growable: false);
            if (_arePointsValid(points)) return points;
          }
        } catch (_) {
          // fall through to polyline decoding
        }
      }
      // Try polyline with precision 5, then 6
      final p5 = _decodePolyline(geometry, precision: 5);
      if (_arePointsValid(p5)) return p5;
      final p6 = _decodePolyline(geometry, precision: 6);
      if (_arePointsValid(p6)) return p6;
      throw Exception(
        'Failed to decode geometry string into valid coordinates',
      );
    }

    throw Exception('Unexpected geometry format from OpenRouteService');
  }

  // Decodes an encoded polyline string (precision 1e5 by default)
  static List<LatLng> _decodePolyline(String polyline, {int precision = 5}) {
    final List<LatLng> result = [];
    final int len = polyline.length;
    int index = 0;
    int lat = 0;
    int lng = 0;
    final double scale = math.pow(10, precision).toDouble();

    while (index < len) {
      int b;
      int shift = 0;
      int value = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      final int deltaLat = (value & 1) != 0 ? ~(value >> 1) : (value >> 1);
      lat += deltaLat;

      shift = 0;
      value = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < len);
      final int deltaLng = (value & 1) != 0 ? ~(value >> 1) : (value >> 1);
      lng += deltaLng;

      result.add(LatLng(lat / scale, lng / scale));
    }
    return result;
  }

  static bool _arePointsValid(List<LatLng> points) {
    if (points.isEmpty) return false;
    for (final p in points) {
      if (p.latitude < -90 || p.latitude > 90) return false;
      if (p.longitude < -180 || p.longitude > 180) return false;
    }
    return true;
  }
}
