import 'package:flutter/material.dart';

import '../widgets/pokemon_card.dart';

class FavoritesScreen extends StatelessWidget {
  final List<int> ids;
  final ValueChanged<int> onOpenPokemon;

  const FavoritesScreen({
    super.key,
    required this.ids,
    required this.onOpenPokemon,
  });

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no tienes favoritos.',
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ids.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final id = ids[index];

        return PokemonCard(
          id: id,
          name: 'Pokémon #$id',
          onTap: () => onOpenPokemon(id),
        );
      },
    );
  }
}
