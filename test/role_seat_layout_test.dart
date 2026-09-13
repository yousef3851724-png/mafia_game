import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_radical/features/scenarios/role_seat_layout.dart';

void main() {
  test('preserves every role while grouping the main factions', () {
    final input = <String>[
      'شهروند',
      'مافیا',
      'دکتر',
      'پدرخوانده',
      'شکارچی ارشد',
      'شهروند',
      'تک‌تیرانداز',
      'مافیا',
      'کارآگاه',
    ];

    final result = RoleSeatLayout.arrange(input);

    expect(result.length, input.length);
    expect(result.where((r) => r == 'مافیا').length, 2);
    expect(result.where((r) => r == 'شهروند').length, 2);
    expect(result.indexOf('پدرخوانده'), lessThan(result.indexOf('شکارچی ارشد')));
    expect(result.indexOf('شکارچی ارشد'), lessThan(result.indexOf('دکتر')));
    expect(result.last, 'شهروند');
  });

  test('keeps custom roles instead of dropping them', () {
    final result = RoleSeatLayout.arrange(<String>[
      'شهروند',
      'نقش سفارشی',
      'مافیا',
      'شهروند',
    ]);

    expect(result, contains('نقش سفارشی'));
    expect(result.length, 4);
  });
}
