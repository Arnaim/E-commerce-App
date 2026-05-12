class PromoModel {
  final String title;
  final String subtitle;
  final String buttonText;
  final List<String> gradientHexColors;

  PromoModel({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientHexColors,
  });

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      title: map['title'] ?? 'Welcome to Glow & Co.',
      subtitle: map['subtitle'] ?? 'Discover your inner beauty',
      buttonText: map['buttonText'] ?? 'Shop Now',
      gradientHexColors: List<String>.from(map['gradientHexColors'] ?? ['#FCE4EC', '#F8BBD0']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'gradientHexColors': gradientHexColors,
    };
  }
}
