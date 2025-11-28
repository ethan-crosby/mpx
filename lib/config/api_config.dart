import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get spoonacularApiKey {
    return dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  }

  static bool get isConfigured => spoonacularApiKey.isNotEmpty;
}

