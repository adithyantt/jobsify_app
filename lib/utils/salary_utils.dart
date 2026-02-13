/// Utility functions for parsing and handling salary strings
class SalaryUtils {
  /// Extracts the minimum salary from a salary string
  /// Examples:
  /// - "₹800-1000/day" -> 800
  /// - "₹15,000 (complete work)" -> 15000
  /// - "₹500/hour" -> 500
  /// - null or empty -> null
  static int? extractMinSalary(String? salary) {
    if (salary == null || salary.isEmpty) return null;

    // Remove currency symbol and extra text
    String cleaned = salary.replaceAll('₹', '').replaceAll(',', '');

    // Extract numbers using regex
    RegExp regExp = RegExp(r'\d+');
    Iterable<Match> matches = regExp.allMatches(cleaned);

    if (matches.isEmpty) return null;

    // Get all numbers and return the smallest one (min salary)
    List<int> numbers = matches.map((m) => int.parse(m.group(0)!)).toList();
    return numbers.reduce((a, b) => a < b ? a : b);
  }

  /// Checks if a salary falls within the given range
  static bool isSalaryInRange(String? salary, int? minSalary, int? maxSalary) {
    if (salary == null || salary.isEmpty)
      return true; // No salary means include
    if (minSalary == null && maxSalary == null) return true; // No filter

    int? jobSalary = extractMinSalary(salary);
    if (jobSalary == null) return true; // Can't parse, include

    if (minSalary != null && jobSalary < minSalary) return false;
    if (maxSalary != null && jobSalary > maxSalary) return false;

    return true;
  }
}
