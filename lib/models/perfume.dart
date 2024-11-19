// models/perfume.dart
class Perfume {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String perfumeDescription;
  final double rating;
  final String url;

  Perfume({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.perfumeDescription,
    required this.rating,
    required this.url,
  });

  factory Perfume.fromJson(Map<String, dynamic> json) {
    return Perfume(
      id: json['id']?.toString() ?? '',
      name: json['perfume']?.toString() ?? 'Unknown Perfume',
      brand: json['brand']?.toString() ?? 'Unknown Brand',
      imageUrl: json['image']?.toString() ?? 'https://placeholder.com/perfume',
      perfumeDescription:
          json['description']?.toString() ?? 'No description available',
      rating: _parseRating(json['rating']),
      url: json['url']?.toString() ?? '',
    );
  }

  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    try {
      if (rating is int) return rating.toDouble();
      if (rating is double) return rating;
      if (rating is String) return double.tryParse(rating) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Untuk debugging
  @override
  String toString() {
    return 'Perfume{id: $id, name: $name, brand: $brand, rating: $rating}';
  }

  // Untuk membandingkan objek perfume
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Perfume &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          brand == other.brand;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ brand.hashCode;
}
