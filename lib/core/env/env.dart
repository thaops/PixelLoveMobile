import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://your-api.com/api';

  static String get oneSignalKey => dotenv.env['ONE_SIGNAL_KEY'] ?? '';

  static String get payosClientId => dotenv.env['PAYOS_CLIENT_ID'] ?? '';
}
