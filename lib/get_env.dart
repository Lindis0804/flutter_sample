import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVariable {
  final String vietmapApiKey = dotenv.env['VIETMAP_API_KEY'] ?? 'default_key';
}
