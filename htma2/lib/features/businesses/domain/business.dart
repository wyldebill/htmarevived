class Business {
  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;

  factory Business.fromJson(String id, Map<Object?, Object?> map) {
    final coordinates = map['coordinates'];
    final coordinateMap = coordinates is Map<Object?, Object?>
        ? coordinates
        : <Object?, Object?>{};

    return Business(
      id: id,
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      latitude: _toDouble(map['lat'] ?? coordinateMap['lat']),
      longitude: _toDouble(map['lng'] ?? coordinateMap['lng']),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
