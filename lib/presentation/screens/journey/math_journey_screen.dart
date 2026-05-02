import 'package:flutter/material.dart';
import 'package:math_timetravel/core/constants/math_eras.dart';
import 'package:math_timetravel/core/constants/era_theme.dart';
import 'math_era_detail_screen.dart';

/// Vertical timeline of [MathEra]s. Tapping an era opens its detail screen
/// where the AI generates contextualized BNCC exercises.
///
/// This is the **Math TimeTravel** journey entry point — sibling of the
/// English TimeTravel app. Both share the same time-travel metaphor but
/// each has its own subject-specific era list and prompts.
class MathJourneyScreen extends StatelessWidget {
  const MathJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jornada Matemática'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: MathEra.all.length,
        itemBuilder: (context, index) {
          final era = MathEra.all[index];
          final theme = EraTheme.of(era);
          final isLast = index == MathEra.all.length - 1;

          return _EraTimelineCard(
            era: era,
            theme: theme,
            isLast: isLast,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MathEraDetailScreen(era: era),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EraTimelineCard extends StatelessWidget {
  final MathEra era;
  final EraTheme theme;
  final bool isLast;
  final VoidCallback onTap;

  const _EraTimelineCard({
    required this.era,
    required this.theme,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail
          SizedBox(
            width: 56,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.seedColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.seedColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(theme.icon, color: Colors.white, size: 20),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.seedColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          // Era card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 12, 16),
              child: Card(
                color: theme.seedColor.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.seedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          era.namePt,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.seedColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          era.yearRange,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          era.description,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: era.bnccThemes
                              .take(3)
                              .map((t) => Chip(
                                    label: Text(
                                      t.replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                    backgroundColor:
                                        theme.seedColor.withValues(alpha: 0.15),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
