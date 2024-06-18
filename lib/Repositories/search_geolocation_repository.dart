import 'dart:convert' as convert;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:http/http.dart' as http;

class SearchGeolLocationRepository {
  SearchGeolLocationRepository._();

  static final SearchGeolLocationRepository instance =
      SearchGeolLocationRepository._();

  final String _url =
      "https://nominatim.openstreetmap.org/search?f=json&format=json&";

  Future<GeoPoint> getGeoLocationByAddress(Address address) async {
    final url = Uri.parse("$_url"
        "street=${address.street}&"
        "city=${address.city}&"
        "country=Brazil");

    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode <= 203) {
      final json = convert.jsonDecode(response.body) as List<dynamic>;

      if (json.isEmpty) {
        throw Exception("Endereço não encontrado");
      }

      final first = json.first as Map<String, dynamic>;

      final lat = first["lat"] as String;
      final lon = first["lon"] as String;

      return GeoPoint(double.parse(lat), double.parse(lon));
    }

    throw Exception("Endereço não encontrado");
  }
}
