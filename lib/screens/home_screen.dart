import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onOpenPokemon;

  const HomeScreen({
    super.key,
    required this.onOpenPokemon,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random random = Random();

  int? randomId;

  void generateRandomPokemon() {
    setState(() {
      randomId = random.nextInt(1025) + 1;
    });
  }

  // Encabezado con imagen local y Stack
  Widget buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pokebola decorativa de fondo
          Positioned(
            right: 0,
            top: 0,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/pokeball.png',
                width: 115,
                height: 115,
              ),
            ),
          ),

          // Contenido principal
          Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Bienvenido a PokéExplorer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Descubre el mundo Pokémon',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagenes locales
            buildWelcomeHeader(),

            const SizedBox(height: 20),

            // Funcion aleatoria
            FilledButton.icon(
              onPressed: generateRandomPokemon,
              icon: const Icon(Icons.casino),
              label: const Text(
                'Pokémon aleatorio',
              ),
            ),

            // Tarjeta reutilizable
            if (randomId != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 190,
                height: 190,
                child: PokemonCard(
                  id: randomId!,
                  name: 'Pokémon #$randomId',
                  onTap: () {
                    widget.onOpenPokemon(randomId!);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
