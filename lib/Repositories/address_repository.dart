import 'dart:convert' as convert;

import 'package:logsan_app/Utils/Classes/address.dart';
import 'package:http/http.dart' as http;

class AddressRepository {
  AddressRepository._();

  static final AddressRepository instance = AddressRepository._();

  Future<Address> getAddressByCep(String cep) async {
    final url = Uri.https("viacep.com.br", "/ws/$cep/json");
    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode <= 203) {
      final json = convert.jsonDecode(response.body) as Map<String, dynamic>;

      return Address.fromJson(json);
    }

    throw Exception("Cep não foi encontrado");
  }
}
