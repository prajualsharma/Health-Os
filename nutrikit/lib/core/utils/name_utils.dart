/// Title-cases each word: "ayushi naidu" → "Ayushi Naidu".
String toTitleCaseName(String input) {
  if (input.trim().isEmpty) return input;
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
