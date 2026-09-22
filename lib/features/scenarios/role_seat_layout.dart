/// Canonical, deterministic ordering for visible player seats.
///
/// Roles are grouped by faction first, then by strategic importance. The
/// ordering is deterministic so the table never looks randomly shuffled.
class RoleSeatLayout {
  RoleSeatLayout._();

  static const List<String> _mafiaPriority = <String>[
    'پدرخوانده',
    'مافیا',
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
    'دادستان',
    'جک',
    'شهردار',
  ];

  /// Returns a deterministic seat order without changing role counts.
  ///
  /// The visible table is grouped as: mafia, hunter, independent, town
  /// specials, custom roles, then ordinary citizens.
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
