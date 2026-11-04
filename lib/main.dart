import 'package:flutter/material.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PokeExplorer());
}

class PokeExplorer extends StatelessWidget {
  const PokeExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéExplorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: const AppShell(),
    );
  }
}
