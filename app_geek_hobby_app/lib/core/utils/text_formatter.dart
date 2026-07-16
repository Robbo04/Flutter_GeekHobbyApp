/// Text formatting utilities for cleaning and normalizing descriptions
class TextFormatter {
  /// Normalizes text descriptions from AniList by:
  /// - Removing HTML tags
  /// - Converting HTML line breaks to newlines
  /// - Collapsing multiple consecutive newlines
  /// - Trimming excess whitespace
  static String normalizeDescription(String text) {
    return text
        // Replace HTML line breaks with newlines
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        // Remove HTML tags (italic, bold, etc.)
        .replaceAll(RegExp(r'<[^>]+>', caseSensitive: false), '')
        // Collapse multiple consecutive newlines (keep max 2 for one blank line)
        .replaceAll(RegExp(r'\n\n\n+'), '\n\n')
        // Trim excess whitespace on each line
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        // Remove leading/trailing whitespace from entire text
        .trim();
  }
}
