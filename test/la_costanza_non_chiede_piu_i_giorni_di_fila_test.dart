import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LA COSTANZA NON CHIEDE PIU' I GIORNI DI FILA. Ordine AS voce 12, corpus D.
///
/// **Perche' cambia.** La misura della voce AR.04 aveva mostrato zero feste nel
/// secondo e nel terzo mese: con la serie consecutiva chi non apre l'app tutti
/// i giorni non la completa mai, e la scala essendo sequenziale si blocca li'
/// per sempre. Il corpus D chiede tanti giorni dentro un arco piu' largo.
///
/// **Cosa si misura**: che il corpus vivo sia la revisione D2, ordine AU voce
/// 03, che sostituisce la D correggendo le finestre impossibili; che le costanze
/// larghe esistano davvero nei tre sentieri; e che il diario sappia contare i
/// giorni dentro l'arco, saltandone uno in mezzo, che e' esattamente il caso
/// che prima azzerava tutto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il corpus vivo e la revisione D2', () {
    final generatore =
        File('tool/genera_sentieri_dal_corpus.py').readAsStringSync();
    expect(generatore.contains('Traguardi_165_Revisione_D2.json'), isTrue,
        reason: 'il generatore legge ancora un corpus vecchio');
    expect(File('docs/corpus/Traguardi_165_Revisione_D2.json').existsSync(),
        isTrue);
  });

  test('le costanze larghe ci sono, e nessuna chiede l impossibile', () {
    var quante = 0;
    final impossibili = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      final c = t.condizione;
      if (c is! GiorniDentroUnArco) continue;
      quante++;
      if (c.arco < c.quanti) {
        impossibili.add('${t.id}: ${c.quanti} giorni dentro ${c.arco}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 12: costanze larghe nel codice $quante, impossibili '
        '${impossibili.length}');
    expect(quante, greaterThanOrEqualTo(15),
        reason: 'le costanze larghe sono $quante: il corpus D non e stato '
            'applicato, oppure la regola non le riconosce piu');
    expect(impossibili, isEmpty,
        reason: 'queste condizioni chiedono piu giorni di quanti l arco ne '
            'contenga, e non si possono raggiungere: '
            '${impossibili.join("; ")}');
  });

  test('il diario conta i giorni dentro l arco, anche saltandone uno',
      () async {
    // **IL CASO CHE PRIMA AZZERAVA TUTTO**: cinque giorni con un buco in
    // mezzo. Con la serie consecutiva il conto tornava a uno; con l'arco
    // restano quattro giorni dentro sei.
    final oggi = orologioDelleProve();
    // **LA CHIAVE SI CHIEDE ALLA PORTA VERA.** Comporla a mano qui aveva
    // prodotto '2026-08-02' mentre il diario scrive '2026-8-2': la prova
    // segnava giorni che il diario non riconosceva, e contava zero.
    String chiave(int indietro) =>
        ConfineDelGiorno.chiaveDi(oggi.subtract(Duration(days: indietro)));

    SharedPreferences.setMockInitialValues({
      'cammino.giorniPerRito': jsonEncode({
        // Oggi, ieri, tre giorni fa e cinque giorni fa: il buco e' due giorni
        // fa, ed e' proprio la domenica saltata di cui parla la voce.
        'oracolo': [chiave(5), chiave(3), chiave(1), chiave(0)],
      }),
    });
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final dentroSei = diario.giorniDelRitoNellArco('oracolo', 6);
    final dentroDue = diario.giorniDelRitoNellArco('oracolo', 2);
    // ignore: avoid_print
    print('ORDINE AS VOCE 12: giorni con oracolo dentro sei $dentroSei, '
        'dentro due $dentroDue');
    expect(dentroSei, 4,
        reason: 'l arco di sei giorni non conta i quattro giorni segnati: la '
            'costanza larga non funziona');
    expect(dentroDue, 2,
        reason: 'un arco stretto deve contare solo cio che ci sta dentro');
  });

  test('un traguardo di costanza larga matura senza giorni di fila', () async {
    final oggi = orologioDelleProve();
    // **LA CHIAVE SI CHIEDE ALLA PORTA VERA.** Comporla a mano qui aveva
    // prodotto '2026-08-02' mentre il diario scrive '2026-8-2': la prova
    // segnava giorni che il diario non riconosceva, e contava zero.
    String chiave(int indietro) =>
        ConfineDelGiorno.chiaveDi(oggi.subtract(Duration(days: indietro)));

    // Il primo traguardo di costanza larga del corpus, qualunque sia.
    final traguardo = Sentieri.tuttiITraguardi
        .firstWhere((t) => t.condizione is GiorniDentroUnArco);
    final c = traguardo.condizione as GiorniDentroUnArco;
    // Tanti giorni quanti ne chiede, sparsi dentro il suo arco e MAI di fila.
    final giorni = <String>{
      for (var i = 0; i < c.quanti; i++)
        chiave((i * 2) % c.arco),
    }.toList();
    SharedPreferences.setMockInitialValues({
      'cammino.giorniPerRito': jsonEncode({c.rito: giorni}),
    });
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final quanti = diario.giorniDelRitoNellArco(c.rito, c.arco);
    // ignore: avoid_print
    print('ORDINE AS VOCE 12: ${traguardo.id} chiede ${c.quanti} giorni di '
        '${c.rito} dentro ${c.arco}; segnati ${giorni.length}, contati '
        '$quanti');
    expect(quanti, greaterThanOrEqualTo(c.quanti),
        reason: 'i giorni sparsi dentro l arco non bastano a maturare '
            '${traguardo.id}: la costanza larga non serve a niente');
    final stato = StatoDelCammino(costanzeLarghe: {'${c.rito}:${c.arco}': quanti});
    expect(c.raggiunto(stato), isTrue,
        reason: 'la condizione non si dichiara raggiunta nemmeno coi giorni '
            'contati');
  });
}
