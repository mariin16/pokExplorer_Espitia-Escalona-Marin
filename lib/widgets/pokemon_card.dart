import 'package:flutter/material.dart';

class PokemonCard extends StatelessWidget {
  final int id;
  final String name;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.id,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://raw.githubusercontent.com/'
              'PokeAPI/sprites/master/sprites/'
              'pokemon/$id.png',
              height: 100,
              errorBuilder: (context, error, stack) {
                return const Icon(
                  Icons.image,
                  size: 60,
                );
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Text(
                name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('#$id'),
          ],
        ),
      ),
    );
  }
}
