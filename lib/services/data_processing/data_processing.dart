

class DataProcessing {
  static List<String>? sanitizeLinks(List<String>? links) {
    if (links == null) return null;
    final seen = <String>{};
    final out = <String>[];
    for (final raw in links) {
      if (out.length >= 5) break;
      final s = raw.trim();
      if (s.isEmpty) continue;
      if (seen.add(s)) out.add(s);
    }
    return out;
  }
}