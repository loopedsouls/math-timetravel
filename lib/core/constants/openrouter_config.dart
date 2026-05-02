import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenRouterConfig {
  OpenRouterConfig._();

  static const String _envVarName = 'OPENROUTER_API_KEY';

  static String? get apiKey {
    try {
      final envKey = Platform.environment[_envVarName];
      if (envKey != null && envKey.isNotEmpty) {
        return envKey;
      }

      final dotenvKey = dotenv.env[_envVarName];
      if (dotenvKey != null && dotenvKey.isNotEmpty) {
        return dotenvKey;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting OpenRouter API key: $e');
      }
      return null;
    }
  }

  static bool get isAvailable => apiKey != null && apiKey!.isNotEmpty;

  static const List<String> freeModels = [
    'openai/gpt-oss-120b:free',
    'minimax/minimax-m2.5:free',
    'z-ai/glm-4.5-air:free',
    'tencent/hy3-preview:free',
  ];

  static const String defaultModel = 'openai/gpt-oss-120b:free';
}