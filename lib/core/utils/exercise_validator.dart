/// Utility for validating AI‑generated math exercise JSON.
///
/// The validator is defensive: any malformed input results in a
/// [ExerciseValidationResult] with `isValid` set to `false` and a list of
/// error messages. No exceptions are thrown.
class ExerciseValidator {
  // Private constructor to prevent instantiation.
  ExerciseValidator._();

  /// Validates a raw exercise map.
  ///
  /// Returns an [ExerciseValidationResult] containing whether the input is
  /// valid, a list of error messages, and a sanitized copy of the map when
  /// valid. The [expectedAno] parameter, if supplied, must match the optional
  /// `ano` field (case‑insensitive, trimmed).
  static ExerciseValidationResult validate(
    Map<String, dynamic>? raw, {
    String? expectedAno,
  }) {
    final errors = <String>[];
    if (raw == null) {
      errors.add('Exercise data is null.');
      return ExerciseValidationResult(false, errors, null);
    }

    // Helper to fetch a trimmed string value.
    String? _trimString(dynamic value) =>
        value is String ? value.trim() : null;

    // 1. pergunta
    final perguntaRaw = raw['pergunta'];
    final pergunta = _trimString(perguntaRaw);
    if (pergunta == null || pergunta.isEmpty) {
      errors.add('Missing or empty "pergunta".');
    } else {
      if (pergunta.length < 10) {
        errors.add('"pergunta" must be at least 10 characters.');
      }
      if (pergunta.length > 500) {
        errors.add('"pergunta" must not exceed 500 characters.');
      }
      if (_containsForbiddenTag(pergunta)) {
        errors.add('"pergunta" contains forbidden content.');
      }
    }

    // 2. opcoes
    final opcoesRaw = raw['opcoes'];
    List<String>? opcoes;
    if (opcoesRaw is List) {
      opcoes = opcoesRaw
          .whereType<String>()
          .map((s) => s.trim())
          .toList();
      if (opcoes.length != 4) {
        errors.add('"opcoes" must contain exactly 4 items.');
      } else {
        final seen = <String>{};
        for (final opt in opcoes) {
          if (opt.isEmpty) {
            errors.add('All "opcoes" must be non‑empty strings.');
            break;
          }
          if (opt.length > 200) {
            errors.add('Each "opcao" must not exceed 200 characters.');
            break;
          }
          if (!seen.add(opt)) {
            errors.add('Duplicate values found in "opcoes".');
            break;
          }
          if (_containsForbiddenTag(opt)) {
            errors.add('An "opcao" contains forbidden content.');
            break;
          }
        }
      }
    } else {
      errors.add('Missing or invalid "opcoes".');
    }

    // 3. resposta_correta
    final respostaRaw = raw['resposta_correta'];
    final resposta = _trimString(respostaRaw);
    if (resposta == null || resposta.isEmpty) {
      errors.add('Missing or empty "resposta_correta".');
    } else if (opcoes != null && !opcoes.contains(resposta)) {
      errors.add('"resposta_correta" must match one of the "opcoes".');
    }

    // 4. explicacao
    final explicacaoRaw = raw['explicacao'];
    final explicacao = _trimString(explicacaoRaw);
    if (explicacao == null || explicacao.isEmpty) {
      errors.add('Missing or empty "explicacao".');
    } else {
      if (explicacao.length < 10) {
        errors.add('"explicacao" must be at least 10 characters.');
      }
      if (explicacao.length > 2000) {
        errors.add('"explicacao" must not exceed 2000 characters.');
      }
      if (_containsForbiddenTag(explicacao)) {
        errors.add('"explicacao" contains forbidden content.');
      }
    }

    // 5. ano validation (optional)
    if (expectedAno != null) {
      final anoRaw = raw['ano'];
      final ano = _trimString(anoRaw);
      if (ano == null || ano.toLowerCase() != expectedAno.trim().toLowerCase()) {
        errors.add('"ano" does not match the expected value.');
      }
    }

    final isValid = errors.isEmpty;
    Map<String, dynamic>? sanitized;
    if (isValid) {
      sanitized = {
        'pergunta': pergunta!,
        'opcoes': opcoes!,
        'resposta_correta': resposta!,
        'explicacao': explicacao!,
        if (raw.containsKey('ano')) 'ano': _trimString(raw['ano'])!,
      };
    }

    return ExerciseValidationResult(isValid, errors, sanitized);
  }

  static bool _containsForbiddenTag(String text) {
    final lowered = text.toLowerCase();
    return lowered.contains('<script') ||
        lowered.contains('<iframe') ||
        lowered.contains('javascript:');
  }
}

/// Result of an exercise validation.
class ExerciseValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, dynamic>? sanitized;

  ExerciseValidationResult(this.isValid, this.errors, this.sanitized);
}