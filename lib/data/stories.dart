class SleepStory {
  final String title;
  final String content;

  SleepStory({required this.title, required this.content});
}

final List<SleepStory> stories = [
  SleepStory(
    title: "The Quiet Forest",
    content: """
In a peaceful forest where the wind whispered softly,
the trees swayed under the moonlight.
Your breath slows as you walk deeper,
feeling safe, calm, and relaxed...
""",
  ),
  SleepStory(
    title: "Ocean Drift",
    content: """
You float gently on warm ocean waters.
Soft waves lift and lower you.
The stars above glow quietly,
guiding you toward deep restful sleep...
""",
  ),
];
