/// Represents a mathematical era — a chunk of math history with its own
/// flavor of problems. Pure Dart so it can be used in tests and CLI tools.
///
/// Each [MathEra] maps to BNCC-friendly themes that the AI tutor uses to
/// contextualize exercises (e.g. "Pythagorean theorem in a Greek temple",
/// "compound interest at a Renaissance bank").
class MathEra {
  final String id;
  final String namePt;
  final String nameEn;
  final String yearRange;
  final String description;

  /// BNCC-aligned topic tags the AI uses to generate exercises.
  final List<String> bnccThemes;

  /// Suggested age band (Ensino Fundamental II = 6º–9º ano).
  final List<int> bnccGrades;

  const MathEra._({
    required this.id,
    required this.namePt,
    required this.nameEn,
    required this.yearRange,
    required this.description,
    required this.bnccThemes,
    required this.bnccGrades,
  });

  static const babylonian = MathEra._(
    id: 'babylonian',
    namePt: 'Babilônia e Egito',
    nameEn: 'Babylonian & Egyptian',
    yearRange: '3000 – 500 a.C.',
    description:
        'O nascimento da matemática prática: contagem, medição de terras '
        'após as enchentes do Nilo, sistema sexagesimal e frações unitárias.',
    bnccThemes: [
      'sistema_de_numeração',
      'frações_unitárias',
      'medidas_de_comprimento_e_área',
      'razão_e_proporção',
    ],
    bnccGrades: [6, 7],
  );

  static const greek = MathEra._(
    id: 'greek',
    namePt: 'Grécia Antiga',
    nameEn: 'Ancient Greek',
    yearRange: '600 a.C. – 300 d.C.',
    description:
        'Geometria como linguagem do universo. Pitágoras, Euclides, Tales — '
        'a era em que a matemática virou demonstração rigorosa.',
    bnccThemes: [
      'geometria_plana',
      'teorema_de_pitágoras',
      'área_e_perímetro',
      'razão_e_semelhança',
    ],
    bnccGrades: [7, 8, 9],
  );

  static const islamic = MathEra._(
    id: 'islamic',
    namePt: 'Era Islâmica',
    nameEn: 'Islamic Golden Age',
    yearRange: '800 – 1400',
    description:
        'Bagdá, Córdoba, Samarcanda. Al-Khwarizmi inventa a álgebra, o zero '
        'chega da Índia, e os algarismos arábicos conquistam o mundo.',
    bnccThemes: [
      'álgebra_básica',
      'equações_de_1º_grau',
      'sistema_decimal',
      'porcentagem',
    ],
    bnccGrades: [7, 8],
  );

  static const renaissance = MathEra._(
    id: 'renaissance',
    namePt: 'Renascimento',
    nameEn: 'Renaissance',
    yearRange: '1400 – 1700',
    description:
        'Cardano, Tartaglia, Fermat, Pascal. Equações do 2º e 3º grau, '
        'probabilidade nascendo nos jogos de azar, perspectiva na arte.',
    bnccThemes: [
      'equações_de_2º_grau',
      'probabilidade_básica',
      'estatística_descritiva',
      'progressões',
    ],
    bnccGrades: [8, 9],
  );

  static const modern = MathEra._(
    id: 'modern',
    namePt: 'Era Moderna',
    nameEn: 'Modern Era',
    yearRange: '1700 – 1950',
    description:
        'Newton e Leibniz inventam o cálculo. Boole funda a lógica '
        'matemática. Estatística vira ciência. Tudo fica derivável.',
    bnccThemes: [
      'funções_lineares',
      'gráficos_e_proporcionalidade',
      'lógica_básica',
      'estatística',
    ],
    bnccGrades: [8, 9],
  );

  static const digital = MathEra._(
    id: 'digital',
    namePt: 'Era Digital',
    nameEn: 'Digital Era',
    yearRange: '1950 – ?',
    description:
        'Turing, Shannon, criptografia, machine learning. Matemática '
        'discreta domina o mundo: bits, grafos, hashing, IA.',
    bnccThemes: [
      'matemática_financeira',
      'sistemas_de_numeração_binário',
      'lógica_e_algoritmos',
      'estatística_aplicada',
    ],
    bnccGrades: [9],
  );

  static const List<MathEra> all = [
    babylonian,
    greek,
    islamic,
    renaissance,
    modern,
    digital,
  ];

  static MathEra? byId(String id) {
    for (final era in all) {
      if (era.id == id) return era;
    }
    return null;
  }

  @override
  String toString() => 'MathEra($id, $nameEn)';
}
