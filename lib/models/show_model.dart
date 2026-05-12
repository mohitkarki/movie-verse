class Show {
  final int id;
  final String name;
  final String image;
  final double rating;
  final String summary;
  final List<dynamic> genres;
  final String url;

  Show({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.summary,
    required this.genres,
    required this.url,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image']?['medium'] ?? '',
      rating: (json['rating']?['average'] ?? 0).toDouble(),
      summary: json['summary'] ?? '',
      genres: json['genres'] ?? [],
      url: json['url'] ?? '',
    );
  }
}