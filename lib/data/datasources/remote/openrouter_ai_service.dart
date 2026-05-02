import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/openrouter_config.dart';

class OpenRouterAIService {
  static OpenRouterAIService? _instance;

  OpenRouterAIService._();

  static OpenRouterAIService get instance {
    _instance ??= OpenRouterAIService._();
    return _instance!;
  }

  static bool get isAvailable => OpenRouterConfig.isAvailable;

  final HttpClient _httpClient = HttpClient();
  int _queueSize = 0;
  bool _isProcessing = false;

  int get queueSize => _queueSize;
  bool get isProcessing => _isProcessing;

  Future<void> initialize() async {
    if (kDebugMode) print('OpenRouterAIService initialized');
  }

  Future<Map<String, dynamic>?> gerarExercicioPersonalizado({
    required String unidade,
    required String ano,
    required String dificuldade,
    required String tipo,
  }) async {
    if (!isAvailable) return null;

    _isProcessing = true;
    _queueSize++;

    try {
      const systemPrompt = '''Você é um tutor de matemática para estudantes brasileiros do Ensino Fundamental II (6º ao 9º ano).
Siga as diretrizes da BNCC (Base Nacional Comum Curricular).
Gere UMA questão de múltipla escolha em português brasileiro.
Responda APENAS com um objeto JSON válido, sem texto adicional.
O JSON deve ter as seguintes chaves:
- pergunta: string com a questão matemática
- opcoes: array de 4 strings (alternativas A, B, C, D)
- resposta_correta: string que deve ser exatamente igual a uma das opcoes
- explicacao: string com a explicação da resposta''';

      final userPrompt = '''Gere uma questão de matemática para:
- Unidade temática: $unidade
- Ano/faixa: $ano
- Dificuldade: $dificuldade
- Tipo de questão: $tipo

Responda APENAS com JSON válido.''';

      final result = await _chat(
        userPrompt,
        systemPrompt: systemPrompt,
        temperature: 0.7,
        maxTokens: 1024,
      );

      if (result == null) return null;

      final parsed = parseExerciseJson(result);
      if (parsed == null) return null;

      if (!parsed.containsKey('pergunta') ||
          !parsed.containsKey('opcoes') ||
          !parsed.containsKey('resposta_correta') ||
          !parsed.containsKey('explicacao')) {
        return null;
      }

      final opcoes = parsed['opcoes'];
      if (opcoes is! List || opcoes.length != 4) return null;

      final respostaCorreta = parsed['resposta_correta'] as String;
      if (!opcoes.contains(respostaCorreta)) return null;

      return parsed;
    } catch (e) {
      if (kDebugMode) print('Error generating exercise: $e');
      return null;
    } finally {
      _isProcessing = false;
      _queueSize--;
    }
  }

  Future<String?> gerarDica({
    required String pergunta,
    required String contexto,
  }) async {
    if (!isAvailable) return null;

    const systemPrompt = '''Você é um tutor de matemática para estudantes brasileiros do Ensino Fundamental II.
Forneça uma dica que ajude o aluno a resolver a questão, SEM REVELAR A RESPOSTA.
Seja claro e objetivo. Máximo 2 frases.''';

    final userPrompt = 'Pergunta: $pergunta\nContexto: $contexto\nForneça uma dica (sem dar a resposta):';

    try {
      return await _chat(
        userPrompt,
        systemPrompt: systemPrompt,
        temperature: 0.5,
        maxTokens: 256,
      );
    } catch (e) {
      if (kDebugMode) print('Error generating hint: $e');
      return null;
    }
  }

  Future<String?> gerarExplicacao({
    required String pergunta,
    required String resposta,
    required bool correta,
  }) async {
    if (!isAvailable) return null;

    final systemPrompt = '''Você é um tutor de matemática para estudantes brasileiros do Ensino Fundamental II.
Forneça uma explicação passo a passo em linguagem clara, sem jargões técnicos.
Seja didático e encourage o aluno.''';

    final userPrompt = '''Pergunta: $pergunta
Resposta do aluno: $resposta
${correta ? 'O aluno acertou!' : 'O aluno errou.'}
Forneça uma explicação clara:''';

    try {
      return await _chat(
        userPrompt,
        systemPrompt: systemPrompt,
        temperature: 0.7,
        maxTokens: 512,
      );
    } catch (e) {
      if (kDebugMode) print('Error generating explanation: $e');
      return null;
    }
  }

  @visibleForTesting
  static Map<String, dynamic>? parseExerciseJson(String raw) {
    try {
      var jsonStr = raw.trim();

      final fenceRegex = RegExp(r'```json\s*', caseSensitive: false);
      if (fenceRegex.hasMatch(jsonStr)) {
        jsonStr = jsonStr.replaceFirst(fenceRegex, '');
        final endFenceRegex = RegExp(r'```\s*$');
        jsonStr = jsonStr.replaceFirst(endFenceRegex, '');
        jsonStr = jsonStr.trim();
      }

      final firstBrace = jsonStr.indexOf('{');
      final lastBrace = jsonStr.lastIndexOf('}');
      if (firstBrace == -1 || lastBrace == -1) return null;

      jsonStr = jsonStr.substring(firstBrace, lastBrace + 1);

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _chat(
    String prompt, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    final apiKey = OpenRouterConfig.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenRouter API key not available');
    }

    final models = OpenRouterConfig.freeModels;
    final defaultIdx = models.indexOf(OpenRouterConfig.defaultModel);
    final startIdx = defaultIdx >= 0 ? defaultIdx : 0;

    for (var attempt = 0; attempt < 3; attempt++) {
      final modelIdx = (startIdx + attempt) % models.length;
      final model = models[modelIdx];

      try {
        final messages = <Map<String, dynamic>>[];
        if (systemPrompt != null && systemPrompt.isNotEmpty) {
          messages.add({'role': 'system', 'content': systemPrompt});
        }
        messages.add({'role': 'user', 'content': prompt});

        final body = jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': temperature,
        });

        final uri = Uri.parse(ApiEndpoints.openRouterChat);
        final request = await _httpClient.postUrl(uri);

        request.headers.set('Authorization', 'Bearer $apiKey');
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('HTTP-Referer', 'https://mathquest.app');
        request.headers.set('X-Title', 'Math TimeTravel');
        request.write(body);

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        final statusCode = response.statusCode;

        if (statusCode == 429 || statusCode >= 500) {
          if (kDebugMode) print('Model $model failed with $statusCode, trying next...');
          continue;
        }

        if (statusCode != 200) {
          final errorJson = jsonDecode(responseBody);
          final error = errorJson['error']?['message'] ?? errorJson['error'];
          if (error != null && error.toString().contains('error')) {
            if (kDebugMode) print('Model $model error: $error, trying next...');
            continue;
          }
          throw Exception('API error: $statusCode - $responseBody');
        }

        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = responseData['choices'] as List?;
        if (choices == null || choices.isEmpty) {
          if (kDebugMode) print('No choices in response, trying next...');
          continue;
        }

        final message = choices[0]['message'] as Map<String, dynamic>?;
        if (message == null) {
          if (kDebugMode) print('No message in choice, trying next...');
          continue;
        }

        var content = message['content'] as String?;
        if (content == null || content.isEmpty) {
          content = message['reasoning'] as String?;
        }
        if (content == null || content.isEmpty) {
          if (kDebugMode) print('Empty content, trying next...');
          continue;
        }

        return content;
      } catch (e) {
        if (attempt == 2) {
          if (kDebugMode) print('All models failed: $e');
          rethrow;
        }
        if (kDebugMode) print('Model $model failed: $e, trying next...');
      }
    }

    return null;
  }
}