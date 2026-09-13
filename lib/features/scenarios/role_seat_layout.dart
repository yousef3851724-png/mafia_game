/// Canonical, deterministic ordering for visible player seats.
///
/// The game should not randomly shuffle roles because that makes the visual
/// table look arbitrary. Roles are grouped by game faction and importance,
/// while preserving every occurrence exactly once.
class RoleSeatLayout {
  RoleSeatLayout._();

  static const List<String> _mafiaPriority = <String>[
    'پدرخوانده',
    'مافیا',
    'جک',
    'دادستان',
  ];

  static const List<String> _hunterPriority = <String>[
    'شکارچی ارشد',
    'تک‌تیرانداز',
    'ردیاب',
  ];

  static const List<String> _independentPriority = <String>[
    'قاتل مستقل',
    'جوکر',
    'زامبی',
    'دوئلیست',
  ];

  static const List<String> _townSpecialPriority = <String>[
    'دکتر',
    'محافظ',
    'کارآگاه',
    'بازپرس',
    'روانشناس',
    'تکاور',
    'مذاکره',
    'شهردار',
    'تک‌تیرانداز',
    'ردیاب',
  ];

  /// Returns a deterministic seat order without changing role counts.
  ///
  /// Faction blocks are kept together: mafia, hunter, independent, town
  /// specials, then ordinary citizens. Unknown/custom roles are retained in
  /// their original relative order at the end.
  static List<String> arrange(Iterable<String> roles) {
    final remaining = List<String>.from(roles);
    final result = <String>[];

    void takeInPriority(List<String> priority) {
      for (final role in priority) {
        for (var i = remaining.length - 1; i >= 0; i--) {
          if (remaining[i] == role) {
            result.add(remaining.removeAt(i));
          }
        }
      }
    }

    takeInPriority(_mafiaPriority);
    takeInPriority(_hunterPriority);
    takeInPriority(_independentPriority);
    takeInPriority(_townSpecialPriority);

    final citizens = <String>[];
    final custom = <String>[];
    for (final role in remaining) {
      if (role == 'شهروند') {
        citizens.add(role);
      } else {
        custom.add(role);
      }
    }
    result.addAll(custom);
    result.addAll(citizens);
    return result;
  }
}
