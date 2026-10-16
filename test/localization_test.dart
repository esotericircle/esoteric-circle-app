import 'package:esoteric_circle/core/l10n/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localizzazione a chiavi: italiano di default, l'inglese si aggiunge senza
/// toccare la UI. Ogni chiave ripiega sull'italiano e infine sul fallback.
void main() {
  tearDown(() => AppStrings.languageCode = 'it');

  test('Italiano di default per la barra e le funzioni', () {
    AppStrings.languageCode = 'it';
    expect(AppStrings.navSantuario, 'Il Cerchio');
    expect(AppStrings.navPassport, 'Passport');
    expect(AppStrings.functionTitle('synastry_vip', fallback: 'X'),
        'Sinastria VIP');
  });

  test('L\'inglese si attiva cambiando la lingua, senza toccare il codice', () {
    AppStrings.languageCode = 'en';
    expect(AppStrings.navSantuario, 'The Circle');
    expect(AppStrings.functionTitle('synastry_vip', fallback: 'X'),
        'VIP Synastry');
    // Passport resta invariato come termine di brand.
    expect(AppStrings.navPassport, 'Passport');
  });

  test('Una chiave senza traduzione ripiega sul fallback fornito', () {
    AppStrings.languageCode = 'it';
    expect(
        AppStrings.functionTitle('non_esiste', fallback: 'Ripiego'), 'Ripiego');
  });
}
