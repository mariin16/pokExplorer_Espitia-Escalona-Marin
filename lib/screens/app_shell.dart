import 'package:flutter/material.dart';

import '../services/favorites_service.dart';

import 'home_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'detail_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedTab = 0;

  final Set<int> favorites = {};

  bool loadingFavorites = true;

  final List<String> titles = [
    'Inicio',
    'Pokédex',
    'Favoritos',
  ];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Cargar favoritos
  Future<void> loadFavorites() async {
    try {
      final saved = await FavoritesService.loadFavorites();

      if (!mounted) return;

      setState(() {
        favorites
          ..clear()
          ..addAll(saved);

        loadingFavorites = false;
      });
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');

      if (!mounted) return;

      setState(() {
        loadingFavorites = false;
      });
    }
  }

  // Agregar o eliminar favoritos
  Future<void> toggleFavorite(int id) async {
    setState(() {
      if (!favorites.add(id)) {
        favorites.remove(id);
      }
    });

    try {
      await FavoritesService.saveFavorites(
        favorites,
      );
    } catch (e) {
      debugPrint('Error guardando favoritos: $e');
    }
  }

  // Abrir detalles de un Pokemon
  void openPokemon(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          id: id,
          isFavorite: favorites.contains(id),
          onToggleFavorite: () => toggleFavorite(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PokéExplorer · ${titles[selectedTab]}',
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: loadingFavorites
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: selectedTab,
              children: [
                HomeScreen(
                  onOpenPokemon: openPokemon,
                ),
                CatalogScreen(
                  onOpenPokemon: openPokemon,
                ),
                FavoritesScreen(
                  ids: favorites.toList()..sort(),
                  onOpenPokemon: openPokemon,
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
