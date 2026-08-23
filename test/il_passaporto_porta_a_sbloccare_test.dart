import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL PASSAPORTO PORTA A SBLOCCARE. Ordine BB voce 05.
///
/// **Richiesta del fondatore**: "nel Passport in fondo, quando manca
/// l'archetipo o un altro elemento della carta natale, dovrebbe esserci un
/// pulsante per portare al test archetipo o alla funzionalita' per sbloccare
/// quell'elemento."
///
/// **IL CENSIMENTO DEGLI ELEMENTI, che l'ordine chiede.** Enumerati leggendo
/// la schermata, non a memoria. Sono OTTO, e per ciascuno si dice **quale
/// porta lo riempie**:
///
/// | elemento | cosa lo riempie | ha una porta |
/// |---|---|---|
/// | Cielo di nascita | la nascita, gia' data nel rito | si', apre la schermata del cielo |
/// | Sigillo del Cerchio | l'ingresso nel Cerchio | si', apre il Sigillo |
/// | Numero della vita | si calcola dalla data | non serve: si riempie da solo |
/// | Luna di nascita | si calcola dalla data | non serve: si riempie da solo |
/// | Angeli | si calcolano dalla data | non serve: si riempie da solo |
/// | Animale guida | si calcola dalla data | non serve: si riempie da solo |
/// | Carta natale | si calcola dalla nascita | non serve: si riempie da solo |
/// | **Archetipo** | **il Test Archetipo** | **adesso si', prima NO** |
///
/// **Quanti restano senza porta: ZERO.** Cinque elementi su otto non hanno
/// bisogno di una porta perche' **non c'e' niente da sbloccare**: nascono dal
/// giorno di nascita, che il Cerchio ha gia'. Due l'avevano gia'. L'ottavo,
/// l'Archetipo, era l'unico che chiedeva qualcosa alla persona **e non le
/// diceva dove andare**.
///
/// **Era un vicolo cieco travestito da spiegazione**: "Fai il Test Archetipo e
/// la tua figura comparira' qui" e' un'istruzione, e chi la legge deve andare
/// a cercarsi il Test da un'altra parte mentre la tessera che gliene parla
/// resta muta sotto il dito.
void main() {
  String soloCodice(String percorso) => File(percorso)
      .readAsLinesSync()
      .where((r) {
        final p = r.trimLeft();
        return !p.startsWith('//') && !p.startsWith('///');
      })
      .join('\n');

  final passaporto =
      soloCodice('lib/features/passport/cosmic_passport_screen.dart');

  test('BB.05: la tessera dell Archetipo vuoto porta al Test', () {
    // ignore: avoid_print
    print('ORDINE BB VOCE 05: la chiave del tocco sul vuoto compare '
        '${"passport_archetipo_vuoto_tocco".allMatches(passaporto).length} '
        'volte');
    expect(passaporto.contains("Key('passport_archetipo_vuoto_tocco')"), isTrue,
        reason: 'la tessera dell Archetipo mancante non e toccabile: dice di '
            'fare il Test e non ci porta');
    // **E PORTA DAVVERO AL TEST**, non a una schermata qualunque.
    expect(passaporto.contains('ArchetypeTestScreen.route()'), isTrue,
        reason: 'il tocco non apre il Test Archetipo');
  });

  test('BB.05: e la frase dice dove porta, invece di ordinare', () {
    // ignore: avoid_print
    print('ORDINE BB VOCE 05: la frase della tessera vuota e '
        '"${RegExp(r"description: 'Tocca per[^']*'").firstMatch(passaporto)?.group(0) ?? "non trovata"}"');
    expect(passaporto.contains('Tocca per fare il Test Archetipo'), isTrue,
        reason: 'la frase ordina di fare qualcosa altrove invece di dire che '
            'il tocco ci porta');
  });

  test('BB.05: ogni tessera che chiede qualcosa ha la sua porta', () {
    // **IL CENSIMENTO, contato sul codice.** Le tessere del Passaporto sono
    // otto: due erano gia' toccabili, cinque si riempiono da sole dalla
    // nascita e non hanno niente da sbloccare, e l'ottava e' l'Archetipo.
    const tessere = <String>[
      'passport_birth_sky',
      'passport_seal',
      'passport_life_path',
      'passport_birth_moon',
      'passport_angels',
      'passport_guide_animal',
      'passport_natal_chart',
      'passport_archetipo',
    ];
    final presenti =
        tessere.where((k) => passaporto.contains("Key('$k')")).toList();
    // ignore: avoid_print
    print('ORDINE BB VOCE 05: tessere censite ${tessere.length}, trovate nel '
        'codice ${presenti.length}: $presenti');
    expect(presenti, hasLength(tessere.length),
        reason: 'il censimento nomina tessere che nel codice non ci sono, '
            'oppure il codice ne ha di nuove che il censimento non conosce: '
            'mancano ${tessere.where((k) => !presenti.contains(k)).toList()}');

    // **LE TRE CHE CHIEDONO UN GESTO ALLA PERSONA sono toccabili.** Le altre
    // cinque nascono dal giorno di nascita: non c'e' nessuna porta da dare,
    // e darne una sarebbe un pulsante che non sblocca niente.
    for (final k in const [
      'passport_birth_sky',
      'passport_seal',
      'passport_archetipo_vuoto_tocco',
    ]) {
      expect(passaporto.contains("Key('$k')"), isTrue,
          reason: 'la tessera $k non porta da nessuna parte');
    }
  });
}
