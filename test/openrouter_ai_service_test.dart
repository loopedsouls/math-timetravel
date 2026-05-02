import 'package:flutter_test/flutter_test.dart';
import 'package:mathquest/data/datasources/remote/openrouter_ai_service.dart';

void main() {
  group('parseExerciseJson', () {
    test('valid JSON returns parsed map', () {
      const raw = '{"pergunta": "Qual é 2+2?", "opcoes": ["3", "4", "5", "6"], "resposta_correta": "4", "explicacao": "2+2=4"}';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNotNull);
      expect(result!['pergunta'], 'Qual é 2+2?');
      expect(result['opcoes'], ['3', '4', '5', '6']);
      expect(result['resposta_correta'], '4');
      expect(result['explicacao'], '2+2=4');
    });

    test('JSON wrapped in ```json fences returns parsed map', () {
      const raw = '''```json
{"pergunta": "Test?", "opcoes": ["A", "B", "C", "D"], "resposta_correta": "A", "explicacao": "Exp"}
```''';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNotNull);
      expect(result!['pergunta'], 'Test?');
      expect(result['opcoes'], ['A', 'B', 'C', 'D']);
    });

    test('JSON with leading explanation text returns parsed map', () {
      const raw = '''Aqui está uma questão de matemática:
{"pergunta": "Test?", "opcoes": ["A", "B", "C", "D"], "resposta_correta": "B", "explicacao": "Exp"}

Espero que goste!''';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNotNull);
      expect(result!['resposta_correta'], 'B');
    });

    test('malformed JSON returns null', () {
      const raw = '{"pergunta": "Test?" "opcoes": ["A"';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNull);
    });

    test('missing keys returns null', () {
      const raw = '{"pergunta": "Test?", "opcoes": ["A", "B", "C", "D"]}';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNull);
    });

    test('wrong opcoes length returns null', () {
      const raw = '{"pergunta": "Test?", "opcoes": ["A", "B"], "resposta_correta": "A", "explicacao": "Exp"}';
      final result = OpenRouterAIService.parseExerciseJson(raw);

      expect(result, isNull);
    });
  });
}