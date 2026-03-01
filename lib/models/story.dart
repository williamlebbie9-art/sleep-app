class Story {
  final String title;
  final String content;
  final String audioPath;
  final bool premium;

  Story({
    required this.title,
    required this.content,
    required this.audioPath,
    this.premium = false,
  });
}
