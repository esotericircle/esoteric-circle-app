import 'dart:io';

import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I GUASTI INNOCUI ARRIVANO AL CRUSCOTTO.** Ordine DV voce 10, 18
/// settembre 2026.
///
/// La coda della memoria ha mandato ogni domanda due volte dall'11 agosto, e
/// la seconda corsa sollevava un errore che la chat annotava come innocuo: in
/// un log che sul telefono non legge nessuno. Un mese di difetto senza una
/// sola traccia visibile. Qui si pretende che l'annotazione arrivi anche al
/// cruscotto, e che l'app vera ce la mandi.
void main() {
  tearDown(() => GuastiVersoIlCruscotto.inoltro = null);

  test('l\'annotazione arriva al cruscotto, con la frase e l\'errore', () {
    final arrivati = <(String, Object)>[];
    GuastiVersoIlCruscotto.inoltro =
        (cosa, errore, traccia) => arrivati.add((cosa, errore));
    final errore = RangeError('coda vuota');
    annotaGuastoInnocuo('salvando un turno nella cronologia di Medora', errore);
    expect(arrivati, hasLength(1),
        reason: 'il guasto e\' rimasto nel log di sviluppo: sul telefono '
            'nessuno lo vede');
    expect(arrivati.single.$1, 'salvando un turno nella cronologia di Medora');
    expect(arrivati.single.$2, same(errore));
  });

  test('un cruscotto che non risponde non trasforma l\'annotazione in guasto',
      () {
    GuastiVersoIlCruscotto.inoltro =
        (cosa, errore, traccia) => throw StateError('cruscotto spento');
    expect(() => annotaGuastoInnocuo('una prova', Exception('x')),
        returnsNormally);
  });

  test(
      'senza cruscotto agganciato, come nelle prove, l\'annotazione resta '
      'nel log e basta', () {
    expect(() => annotaGuastoInnocuo('una prova', Exception('x')),
        returnsNormally);
  });

  test('l\'app vera aggancia il cruscotto a Crashlytics, come non fatale', () {
    final main = File('lib/main.dart').readAsStringSync();
    final aggancio = RegExp(r'GuastiVersoIlCruscotto\.inoltro\s*=[\s\S]{0,200}?'
        r'FirebaseCrashlytics\.instance[\s\S]{0,80}?\.recordError\([\s\S]{0,80}?'
        r'fatal:\s*false');
    expect(aggancio.hasMatch(main), isTrue,
        reason: 'main.dart non manda i guasti innocui a Crashlytics');
    // Dentro il ramo che c'e' solo quando Firebase e' vivo: fuori, nelle
    // prove, toccare Crashlytics solleverebbe.
    final ramo = main.indexOf('if (Firebase.apps.isNotEmpty)');
    final dove = main.indexOf('GuastiVersoIlCruscotto.inoltro');
    final fine = main.indexOf("Briciole.lascia('crashlytics_armato')");
    expect(ramo, isNonNegative);
    expect(dove > ramo && dove < fine, isTrue,
        reason: 'l\'aggancio deve stare nel ramo con Firebase vivo');
  });
}
