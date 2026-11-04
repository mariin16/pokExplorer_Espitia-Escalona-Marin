import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_api.dart';
import '../widgets/pokemon_card.dart';

class CatalogScreen extends StatefulWidget {
  final ValueChanged<int> onOpenPokemon;

  const CatalogScreen({
    super.key,
    required this.onOpenPokemon,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Pokemon> pokemon = [];

  int offset = 0;

  bool busy = false;
  bool hasMore = true;

  String? error;

  @override
  void initState() {
    super.initState();
    loadPage();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadPage() async {
    if (busy || !hasMore) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final next = await PokemonApi.page(offset);

      if (!mounted) return;

      setState(() {
        pokemon.addAll(next);
        offset += next.length;
        hasMore = next.length == 30;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> searchPokemon() async {
    if (busy) return;

    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final result = await PokemonApi.detail(query);

      if (!mounted) return;

      widget.onOpenPokemon(
        result['id'] as int,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar nombre o número',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => searchPokemon(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: busy ? null : searchPokemon,
                icon: const Icon(Icons.search),
                tooltip: 'Buscar',
              ),
            ],
          ),
        ),

        // Errores
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              error!,
              style: const TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Catalogo
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pokemon.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final p = pokemon[index];

              return PokemonCard(
                id: p.id,
                name: p.name,
                onTap: () {
                  widget.onOpenPokemon(p.id);
                },
              );
            },
          ),
        ),

        // Cargando datos
        if (busy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),

        // Cargar mas Pokemon
        if (!busy && hasMore)
          Padding(
            padding: const EdgeInsets.all(8),
            child: OutlinedButton.icon(
              onPressed: loadPage,
              icon: const Icon(Icons.add),
              label: const Text(
                'Cargar otros 30 Pokémon',
              ),
            ),
          ),

        if (!busy && !hasMore)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No hay más Pokémon para cargar.',
            ),
          ),
      ],
    );
  }
}
