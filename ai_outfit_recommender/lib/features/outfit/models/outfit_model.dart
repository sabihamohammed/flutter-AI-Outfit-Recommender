class OutfitModel {
  final String title;
  final String outfit;
  final String colors;
  final String tip;
  final String imageUrl;
  final String weather;
  final String occasion;
  final String gender;

  const OutfitModel({
    required this.title,
    required this.outfit,
    required this.colors,
    required this.tip,
    required this.imageUrl,
    required this.weather,
    required this.occasion,
    required this.gender,
  });

  // 🔥 Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "outfit": outfit,
      "colors": colors,
      "tip": tip,
      "imageUrl": imageUrl,
      "weather": weather,
      "occasion": occasion,
      "gender": gender,
    };
  }

  // 🔥 Convert from JSON
  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      title: json["title"],
      outfit: json["outfit"],
      colors: json["colors"],
      tip: json["tip"],
      imageUrl: json["imageUrl"],
      weather: json["weather"],
      occasion: json["occasion"],
      gender: json["gender"],
    );
  }

  bool isSameLook(OutfitModel other) {
    return title == other.title &&
        outfit == other.outfit &&
        colors == other.colors &&
        tip == other.tip &&
        weather == other.weather &&
        occasion == other.occasion &&
        gender == other.gender;
  }
}
