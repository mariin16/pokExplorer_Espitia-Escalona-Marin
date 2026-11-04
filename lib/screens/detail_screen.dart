import 'package:flutter/material.dart';

import '../services/pokemon_api.dart';
import '../widgets/pokemon_map.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DetailScreen({
    super.key,
    required this.id,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> pokemonFuture;
  late bool favorite;

  @override
  void initState() {
    super.initState();

    favorite = widget.isFavorite;

    pokemonFuture = PokemonApi.detail(
      '${widget.id}',
    );
  }

  @override
  void didUpdateWidget(covariant DetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      pokemonFuture = PokemonApi.detail(
        '${widget.id}',
      );
    }

    if (oldWidget.id != widget.id ||
        oldWidget.isFavorite != widget.isFavorite) {
      favorite = widget.isFavorite;
    }
  }

  String getSpriteUrl(int id) {
    return 'https://raw.githubusercontent.com/'
        'PokeAPI/sprites/master/sprites/'
        'pokemon/$id.png';
  }

  Widget buildInformation(
    Map<String, dynamic> pokemon,
  ) {
    final types = (pokemon['types'] as List)
        .map(
          (entry) => entry['type']['name'].toString(),
        )
        .join(', ');

    final abilities = (pokemon['abilities'] as List)
        .map(
          (entry) => entry['ability']['name'].toString(),
        )
        .join(', ');

    final height = (pokemon['height'] as num) / 10;

    final weight = (pokemon['weight'] as num) / 10;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          leading: const Icon(
            Icons.category_outlined,
            color: Colors.red,
          ),
          title: const Text('Tipos'),
          subtitle: Text(types),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(
            Icons.auto_awesome_outlined,
            color: Colors.orange,
          ),
          title: const Text('Habilidades'),
          subtitle: Text(abilities),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(
            Icons.height,
            color: Colors.blue,
          ),
          title: const Text('Altura'),
          subtitle: Text(
            '$height m',
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(
            Icons.monitor_weight_outlined,
            color: Colors.green,
          ),
          title: const Text('Peso'),
          subtitle: Text(
            '$weight kg',
          ),
        ),
      ],
    );
  }

  Widget buildStatistics(
    Map<String, dynamic> pokemon,
  ) {
    final stats = pokemon['stats'] as List;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];

        final name = stat['stat']['name'].toString();

        final value = (stat['base_stat'] as num).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (value / 255).clamp(0.0, 1.0).toDouble(),
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon #${widget.id}',
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: favorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });

              widget.onToggleFavorite();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: pokemonFuture,
        builder: (context, snapshot) {
          // Esperar respuesta de PokeAPI
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostrar errores de consulta
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudo cargar el Pokémon.\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Validar la respuesta
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No hay información disponible.',
              ),
            );
          }

          final pokemon = snapshot.data!;

          final name = pokemon['name'].toString().toUpperCase();

          // Tipos que usara Google Maps
          final pokemonTypes = (pokemon['types'] as List)
              .map(
                (entry) => entry['type']['name'].toString(),
              )
              .toList();

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(
                    getSpriteUrl(widget.id),
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 80,
                      );
                    },
                  ),
                ),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const TabBar(
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.red,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.info_outline,
                      ),
                      text: 'Información',
                    ),
                    Tab(
                      icon: Icon(
                        Icons.bar_chart,
                      ),
                      text: 'Estadísticas',
                    ),
                    Tab(
                      icon: Icon(
                        Icons.map_outlined,
                      ),
                      text: 'Ubicación',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Informacion general
                      buildInformation(pokemon),

                      // Estadisticas
                      buildStatistics(pokemon),

                      // Google Maps - Bogota
                      PokemonMap(
                        pokemonId: widget.id,
                        pokemonName: name,
                        pokemonTypes: pokemonTypes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
