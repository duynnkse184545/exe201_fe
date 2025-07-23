/// Utility class for generating unique IDs across the application
class IdGenerator {
  /// Generates a unique ID based on current timestamp
  static String generate() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Generates a unique ID with a prefix
  static String generateWithPrefix(String prefix) {
    return '${prefix}_${generate()}';
  }
}