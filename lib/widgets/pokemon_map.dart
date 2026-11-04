import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PokemonMap extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;
  final List<String> pokemonTypes;

  const PokemonMap({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
    required this.pokemonTypes,
  });

  @override
  State<PokemonMap> createState() => _PokemonMapState();
}

class _PokemonMapState extends State<PokemonMap> {
  final Random random = Random();
  Set<Marker> markers = <Marker>{};
  int exploration = 1;

  static const LatLng bogota = LatLng(4.675, -74.090);

  // Lugares ficticios de aparicion.
  static const List<_Place> places = [
    _Place('Parque Simon Bolivar', 4.6583, -74.0939, 'fire'),
    _Place('Jardin Botanico', 4.6685, -74.1003, 'grass'),
    _Place('Parque de los Novios', 4.6578, -74.0845, 'water'),
    _Place('Parque de la 93', 4.6768, -74.0488, 'electric'),
    _Place('Humedal Cordoba', 4.6990, -74.0736, 'water'),
    _Place('Humedal Santa Maria del Lago', 4.6946, -74.0926, 'water'),
    _Place('Parque El Virrey', 4.6740, -74.0553, 'grass'),
    _Place('Parque Nacional', 4.6240, -74.0631, 'grass'),
    _Place('Monserrate', 4.6057, -74.0555, 'rock'),
    _Place('Quebrada La Vieja', 4.6537, -74.0480, 'rock'),
    _Place('Plaza de Bolivar', 4.5981, -74.0761, 'fire'),
    _Place('Maloka', 4.6568, -74.1080, 'electric'),
    _Place('Parque La Florida', 4.7291, -74.1437, 'flying'),
    _Place('Parque El Tunal', 4.5757, -74.1308, 'ground'),
    _Place('Parque Timiza', 4.6062, -74.1549, 'grass'),
    _Place('Parque de Usaquen', 4.6951, -74.0305, 'normal'),
    _Place('Parque Ciudad Montes', 4.6120, -74.1117, 'normal'),
    _Place('Humedal Juan Amarillo', 4.7241, -74.1071, 'water'),
    _Place('Mirador de los Nevados', 4.7611, -74.0903, 'rock'),
    _Place('Parque San Andres', 4.6880, -74.1208, 'flying'),
  ];

  static const List<_Pokemon> species = [
    _Pokemon(1, 'Bulbasaur', 'grass'),
    _Pokemon(4, 'Charmander', 'fire'),
    _Pokemon(7, 'Squirtle', 'water'),
    _Pokemon(10, 'Caterpie', 'bug'),
    _Pokemon(16, 'Pidgey', 'flying'),
    _Pokemon(25, 'Pikachu', 'electric'),
    _Pokemon(27, 'Sandshrew', 'ground'),
    _Pokemon(37, 'Vulpix', 'fire'),
    _Pokemon(43, 'Oddish', 'grass'),
    _Pokemon(52, 'Meowth', 'normal'),
    _Pokemon(54, 'Psyduck', 'water'),
    _Pokemon(58, 'Growlithe', 'fire'),
    _Pokemon(60, 'Poliwag', 'water'),
    _Pokemon(69, 'Bellsprout', 'grass'),
    _Pokemon(74, 'Geodude', 'rock'),
    _Pokemon(81, 'Magnemite', 'electric'),
    _Pokemon(95, 'Onix', 'rock'),
    _Pokemon(100, 'Voltorb', 'electric'),
    _Pokemon(111, 'Rhyhorn', 'ground'),
    _Pokemon(129, 'Magikarp', 'water'),
    _Pokemon(133, 'Eevee', 'normal'),
    _Pokemon(143, 'Snorlax', 'normal'),
    _Pokemon(152, 'Chikorita', 'grass'),
    _Pokemon(155, 'Cyndaquil', 'fire'),
    _Pokemon(158, 'Totodile', 'water'),
    _Pokemon(179, 'Mareep', 'electric'),
    _Pokemon(252, 'Treecko', 'grass'),
    _Pokemon(255, 'Torchic', 'fire'),
    _Pokemon(258, 'Mudkip', 'water'),
    _Pokemon(304, 'Aron', 'steel'),
  ];

  @override
  void initState() {
    super.initState();
    generatePokemon();
  }

  @override
  void didUpdateWidget(covariant PokemonMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemonId != widget.pokemonId) {
      generatePokemon();
    }
  }

  String category(String type) {
    switch (type) {
      case 'grass':
      case 'bug':
        return 'grass';
      case 'water':
      case 'ice':
        return 'water';
      case 'electric':
      case 'steel':
        return 'electric';
      case 'fire':
        return 'fire';
      case 'rock':
        return 'rock';
      case 'ground':
        return 'ground';
      case 'flying':
      case 'dragon':
        return 'flying';
      default:
        return 'normal';
    }
  }

  // Una especie siempre recibe el mismo lugar base.
  _Place placeFor(int id, String type) {
    // Ubicaciones especiales de algunos Pokemon.
    const special = <int, int>{
      4: 0,
      1: 1,
      7: 2,
      25: 3,
    };

    if (special.containsKey(id)) {
      return places[special[id]!];
    }

    final matching = places.where((p) => p.type == category(type)).toList();

    final options = matching.isNotEmpty ? matching : places;

    return options[id % options.length];
  }

  // especies que comparten un mismo parque.
  LatLng positionFor(int id, _Place place) {
    if (id == 4 || id == 1 || id == 7 || id == 25) {
      return LatLng(place.lat, place.lng);
    }

    final latOffset = ((id * 17) % 13 - 6) * 0.00008;
    final lngOffset = ((id * 23) % 13 - 6) * 0.00008;

    return LatLng(
      place.lat + latOffset,
      place.lng + lngOffset,
    );
  }

  double markerHue(String type) {
    switch (category(type)) {
      case 'grass':
        return BitmapDescriptor.hueGreen;
      case 'water':
        return BitmapDescriptor.hueAzure;
      case 'fire':
        return BitmapDescriptor.hueRed;
      case 'electric':
        return BitmapDescriptor.hueYellow;
      case 'rock':
        return BitmapDescriptor.hueOrange;
      case 'ground':
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  void generatePokemon() {
    final others = List<_Pokemon>.from(species)
      ..removeWhere((p) => p.id == widget.pokemonId)
      ..shuffle(random);

    final selected = <_Pokemon>[
      _Pokemon(
        widget.pokemonId,
        widget.pokemonName,
        widget.pokemonTypes.isEmpty ? 'normal' : widget.pokemonTypes.first,
      ),
      ...others.take(14),
    ];

    final next = <Marker>{};

    for (final pokemon in selected) {
      final place = placeFor(pokemon.id, pokemon.type);
      final highlighted = pokemon.id == widget.pokemonId;

      next.add(
        Marker(
          markerId: MarkerId('pokemon_${pokemon.id}'),
          position: positionFor(pokemon.id, place),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            highlighted ? BitmapDescriptor.hueAzure : markerHue(pokemon.type),
          ),
          infoWindow: InfoWindow(
            title: '${pokemon.name} #${pokemon.id}',
            snippet: '${place.name} - Aparicion ficticia',
          ),
        ),
      );
    }

    markers = next;
  }

  void exploreAgain() {
    setState(() {
      exploration++;
      generatePokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    final type =
        widget.pokemonTypes.isEmpty ? 'normal' : widget.pokemonTypes.first;

    final place = placeFor(widget.pokemonId, type);

    if (!kIsWeb) {
      return const Center(
        child: Text(
          'Mapa disponible en la version Web.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                '¿Dónde encontrar a ${widget.pokemonName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Puedes encontrarlo en ${place.name}, Bogotá.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Ubicación ficticia de PokéExplorer.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: bogota,
                zoom: 10.5,
              ),
              markers: markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: FilledButton.icon(
            onPressed: exploreAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Explorar nuevamente'),
          ),
        ),
        Text(
          '15 Pokémon visibles · Exploración $exploration',
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _Place {
  final String name;
  final double lat;
  final double lng;
  final String type;

  const _Place(this.name, this.lat, this.lng, this.type);
}

class _Pokemon {
  final int id;
  final String name;
  final String type;

  const _Pokemon(this.id, this.name, this.type);
}
