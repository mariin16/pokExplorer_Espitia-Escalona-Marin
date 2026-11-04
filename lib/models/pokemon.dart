class Pokemon {
  final int id;
  final String name;

  const Pokemon({
    required this.id,
    required this.name,
  });

  factory Pokemon.fromListItem(
    Map<String, dynamic> json,
  ) {
    final uri = Uri.parse(json['url'] as String);

    final id = int.parse(
      uri.pathSegments.where((segment) => segment.isNotEmpty).last,
    );

    return Pokemon(
      id: id,
      name: json['name'] as String,
    );
  }
}
