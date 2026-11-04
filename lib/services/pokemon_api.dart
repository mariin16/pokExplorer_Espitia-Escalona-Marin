import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonApi {
  // Obtener 30 Pokemon por pagina.
  static Future<List<Pokemon>> page(int offset) async {
    final uri = Uri.https(
      'pokeapi.co',
      '/api/v2/pokemon',
      {
        'limit': '30',
        'offset': '$offset',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cargar la lista de Pokémon.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return (data['results'] as List)
        .map(
          (item) => Pokemon.fromListItem(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Buscar un Pokemon por nombre o numero.
  static Future<Map<String, dynamic>> detail(
    String idOrName,
  ) async {
    final query = Uri.encodeComponent(
      idOrName.trim().toLowerCase(),
    );

    final uri = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/$query',
    );

    final response = await http.get(uri);

    if (response.statusCode == 404) {
      throw Exception('Pokémon no encontrado.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo consultar PokéAPI.',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
