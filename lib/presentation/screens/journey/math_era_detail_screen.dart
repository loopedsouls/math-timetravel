import 'package:flutter/material.dart';
import 'package:math_timetravel/core/constants/math_eras.dart';
import 'package:math_timetravel/core/constants/era_theme.dart';
import 'package:math_timetravel/data/datasources/remote/openrouter_ai_service.dart';

/// Detail screen for a [MathEra]. Lets the user generate an
/// era-flavored exercise via [OpenRouterAIService.gerarExercicioPorEra]
/// and reveals the answer + explanation on demand.
class MathEraDetailScreen extends StatefulWidget {
  final MathEra era;
  const MathEraDetailScreen({super.key, required this.era});

  @override
  State<MathEraDetailScreen> createState() => _MathEraDetailScreenState();
}

class _MathEraDetailScreenState extends State<MathEraDetailScreen> {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _exercicio;
  String? _selecionada;
  bool _revelado = false;

  Future<void> _gerarExercicio() async {
    setState(() {
      _loading = true;
      _error = null;
      _exercicio = null;
      _selecionada = null;
      _revelado = false;
    });

    try {
      final result = await OpenRouterAIService.instance.gerarExercicioPorEra(
        era: widget.era,
        dificuldade: 'média',
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (result == null) {
          _error = 'Não foi possível gerar o exercício. Tente novamente.';
        } else {
          _exercicio = result;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Erro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = EraTheme.of(widget.era);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.era.namePt),
        backgroundColor: theme.seedColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EraHeader(era: widget.era, theme: theme),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _gerarExercicio,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bolt),
              label: Text(_loading ? 'Gerando...' : 'Gerar exercício'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.seedColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!,
                      style: TextStyle(color: Colors.red.shade900)),
                ),
              ),
            if (_exercicio != null) _ExerciseCard(
              exercicio: _exercicio!,
              theme: theme,
              selecionada: _selecionada,
              revelado: _revelado,
              onSelect: (opt) => setState(() => _selecionada = opt),
              onRevelar: () => setState(() => _revelado = true),
            ),
          ],
        ),
      ),
    );
  }
}

class _EraHeader extends StatelessWidget {
  final MathEra era;
  final EraTheme theme;
  const _EraHeader({required this.era, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.seedColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.seedColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(theme.icon, color: theme.seedColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(era.namePt,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.seedColor)),
                      Text(era.yearRange,
                          style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(era.description, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 12),
            Text('Temas BNCC desta era:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.seedColor)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: era.bnccThemes
                  .map((t) => Chip(
                        label: Text(
                          t.replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor:
                            theme.seedColor.withValues(alpha: 0.15),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercicio;
  final EraTheme theme;
  final String? selecionada;
  final bool revelado;
  final void Function(String) onSelect;
  final VoidCallback onRevelar;

  const _ExerciseCard({
    required this.exercicio,
    required this.theme,
    required this.selecionada,
    required this.revelado,
    required this.onSelect,
    required this.onRevelar,
  });

  @override
  Widget build(BuildContext context) {
    final pergunta = exercicio['pergunta'] as String? ?? '';
    final opcoes = (exercicio['opcoes'] as List?)?.cast<String>() ?? const [];
    final correta = exercicio['resposta_correta'] as String? ?? '';
    final explicacao = exercicio['explicacao'] as String? ?? '';
    final contextoHist = exercicio['contexto_historico'] as String?;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contextoHist != null && contextoHist.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.seedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.history_edu,
                        color: theme.seedColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(contextoHist,
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(pergunta, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            ...opcoes.map((opt) {
              final isSelected = selecionada == opt;
              final isCorrect = revelado && opt == correta;
              final isWrongPick =
                  revelado && isSelected && opt != correta;
              Color? bg;
              if (isCorrect) bg = Colors.green.shade100;
              if (isWrongPick) bg = Colors.red.shade100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: revelado ? null : () => onSelect(opt),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg ??
                          (isSelected
                              ? theme.seedColor.withValues(alpha: 0.15)
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.seedColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? theme.seedColor
                              : Colors.grey.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(opt)),
                        if (isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (isWrongPick)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (!revelado)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: selecionada == null ? null : onRevelar,
                  child: const Text('Revelar resposta'),
                ),
              ),
            if (revelado) ...[
              const Divider(),
              Text('Explicação:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: theme.seedColor)),
              const SizedBox(height: 4),
              Text(explicacao, style: const TextStyle(height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}
