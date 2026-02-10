class Movement {
  final String name;
  final String imagePath;
  final Duration duration;
  final Duration transition;

  const Movement({
    required this.name,
    required this.imagePath,
    this.duration = const Duration(seconds: 50),
    this.transition = const Duration(seconds: 10),
  });
}

class Flow {
  final String title;
  final List<Movement> movements;

  const Flow({
    required this.title,
    required this.movements,
  });
}
