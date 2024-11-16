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
      id: json['id'],
      name: json['perfume'],
      brand: json['brand'],
      imageUrl: json['image'],
      perfumeDescription: json['description'],
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : 0.0,
      url: json['url'],
    );
  }
}
