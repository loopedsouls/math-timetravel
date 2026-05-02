import 'package:test/test.dart';
import 'package:mathquest/core/utils/exercise_validator.dart';

void main() {
  group('ExerciseValidator', () {
    test('valid input passes validation', () {
      final raw = {
        'pergunta': 'Qual é o resultado de 2 + 2?',
        'opcoes': ['3', '4', '5', '6'],
        'resposta_correta': '4',
        'explicacao': 'A soma de 2 e 2 é 4.',
        'ano': '2023',
      };
      final result = ExerciseValidator.validate(raw, expectedAno: '2023');
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.sanitized, isNotNull);
    });

    test('null input fails validation', () {
      final result = ExerciseValidator.validate(null);
      expect(result.isValid, isFalse);
    });

    test('missing pergunta fails validation', () {
      final raw = {
        'opcoes': ['a', 'b', 'c', 'd'],
        'resposta_correta': 'a',
        'explicacao': 'Explicação válida.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Missing or empty "pergunta".'));
    });

    test('opcoes with wrong length fails validation', () {
      final raw = {
        'pergunta': 'Pergunta válida com tamanho suficiente.',
        'opcoes': ['a', 'b', 'c'],
        'resposta_correta': 'a',
        'explicacao': 'Explicação válida.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('"opcoes" must contain exactly 4 items.'));
    });

    test('opcoes with duplicates fails validation', () {
      final raw = {
        'pergunta': 'Pergunta válida com tamanho suficiente.',
        'opcoes': ['a', 'b', 'a', 'd'],
        'resposta_correta': 'a',
        'explicacao': 'Explicação válida.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Duplicate values found in "opcoes".'));
    });

    test('resposta_correta not in opcoes fails validation', () {
      final raw = {
        'pergunta': 'Pergunta válida com tamanho suficiente.',
        'opcoes': ['a', 'b', 'c', 'd'],
        'resposta_correta': 'e',
        'explicacao': 'Explicação válida.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors,
          contains('"resposta_correta" must match one of the "opcoes".'));
    });

    test('pergunta too short fails validation', () {
      final raw = {
        'pergunta': 'Curto',
        'opcoes': ['a', 'b', 'c', 'd'],
        'resposta_correta': 'a',
        'explicacao': 'Explicação válida.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors,
          contains('"pergunta" must be at least 10 characters.'));
    });

    test('injected script tag in pergunta fails validation', () {
      final raw = {
        'pergunta': '<script>alert(1)</script> Qual é 1+1?',
        'opcoes': ['1', '2', '3', '4'],
        'resposta_correta': '2',
        'explicacao': 'Soma simples.',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('"pergunta" contains forbidden content.'));
    });

    test('whitespace is trimmed in sanitized output', () {
      final raw = {
        'pergunta': '   Qual é 5 * 5?   ',
        'opcoes': [' 20 ', ' 25', '30 ', ' 35 '],
        'resposta_correta': ' 25 ',
        'explicacao': '   Multiplicação básica.   ',
      };
      final result = ExerciseValidator.validate(raw);
      expect(result.isValid, isTrue);
      final s = result.sanitized!;
      expect(s['pergunta'], 'Qual é 5 * 5?');
      expect(s['opcoes'], ['20', '25', '30', '35']);
      expect(s['resposta_correta'], '25');
      expect(s['explicacao'], 'Multiplicação básica.');
    });

    test('expectedAno mismatch fails validation', () {
      final raw = {
        'pergunta': 'Pergunta válida com tamanho suficiente.',
        'opcoes': ['a', 'b', 'c', 'd'],
        'resposta_correta': 'a',
        'explicacao': 'Explicação válida.',
        'ano': '2022',
      };
      final result = ExerciseValidator.validate(raw, expectedAno: '2023');
      expect(result.isValid, isFalse);
      expect(result.errors, contains('"ano" does not match the expected value.'));
    });
  });
}