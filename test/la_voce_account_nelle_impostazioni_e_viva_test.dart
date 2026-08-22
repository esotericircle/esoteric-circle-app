import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA VOCE ACCOUNT NELLE IMPOSTAZIONI E' VIVA. Ordine AZ voce 11, che e' lo
/// stesso lavoro della voce 13 dell'ordine AX. Fatto F9, situazione S35.
///
/// **Era spenta e portava la pillola "Dietro il velo"** mentre l'area account
/// esisteva gia', funzionava, ed era raggiungibile da un'altra parte. Un
/// vicolo cieco messo davanti a una porta aperta.
///
/// **Perche' si legge il file invece di montare la schermata.** Le
/// Impostazioni tirano dentro mezza app: il cielo, il Maestro, la qualita'
/// grafica, la memoria, le notifiche. Montarle qui vorrebbe dire una prova
/// che cade per un motivo qualunque tranne il suo. Qui si sorveglia il fatto
/// preciso: che la voce porti da qualche parte e non porti piu' la pillola.
///
/// **Si guarda il CODICE, non i commenti**: un commento che nomina la pillola
/// e' una spiegazione, non un difetto, e una guardia che ci cadesse sopra
/// sarebbe rossa per se stessa. E' gia' successo due volte in questo
/// repository.
void main() {
  final schermata = File('lib/features/settings/settings_screen.dart');

  String soloCodice() {
    final righe = schermata.readAsLinesSync();
    return righe
        .where((r) {
          final pulita = r.trimLeft();
          return !pulita.startsWith('//') && !pulita.startsWith('///');
        })
        .join('\n');
  }

  test('la voce Account porta da qualche parte', () {
    final codice = soloCodice();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 11: la chiave impostazioni_account compare '
        '${'impostazioni_account'.allMatches(codice).length} volte nel codice');
    expect(codice, contains("Key('impostazioni_account')"),
        reason: 'la voce Account non ha nessuna chiave: non e toccabile, e '
            'nessuna prova potra mai dire se lo diventa');
    expect(codice, contains('AccountScreen.route()'),
        reason: 'la voce Account non porta all area account: e ancora un '
            'vicolo cieco');
  });

  test('la pillola "Dietro il velo" non c e piu in questa schermata', () {
    final codice = soloCodice();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 11: "Dietro il velo" compare '
        '${'Dietro il velo'.allMatches(codice).length} volte nel codice delle '
        'Impostazioni');
    expect(codice.contains('Dietro il velo'), isFalse,
        reason: 'la pillola "Dietro il velo" e ancora nel codice delle '
            'Impostazioni: qualcosa la mostra ancora');
    expect(codice.contains('_VeilBadge'), isFalse,
        reason: 'il componente della pillola e rimasto senza nessuno che lo '
            'usa: e codice morto');
  });

  test('la voce non e piu smorzata', () {
    // `opacity: 0.6` era il modo in cui questa voce diceva "non toccarmi".
    // Toglierla senza togliere la trasparenza avrebbe lasciato una voce viva
    // che sembra spenta, che e' il difetto opposto e altrettanto brutto.
    final codice = soloCodice();
    final vicino = codice.substring(
      (codice.indexOf('impostazioni_account') - 600).clamp(0, codice.length),
      codice.indexOf('impostazioni_account'),
    );
    // ignore: avoid_print
    print('ORDINE AZ VOCE 11: nelle 600 lettere prima della voce, "opacity" '
        'compare ${'opacity'.allMatches(vicino).length} volte');
    expect(vicino.contains('opacity'), isFalse,
        reason: 'la voce Account e toccabile ma resta dipinta come spenta: '
            'nessuno provera a toccarla');
  });
}
