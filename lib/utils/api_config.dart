class ApiConfig {
  // Deprecated. Prefer ApiEndpoints.baseUrl so web/desktop can default to localhost
  // and physical devices can override with --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://10.0.2.2:8000",
  );
}
