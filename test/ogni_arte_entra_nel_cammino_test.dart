import 'dart:io';

import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI ARTE ENTRA NEL CAMMINO, ordine P voce 35.
///
/// **Il fatto.** Verificato sui quattro commit dell'ordine O: le sole
/// schermate collegate a `RegiaDelCammino` erano `rune_draw_screen.dart`,
/// `breath_destiny_screen.dart` e `dawn_rite_screen.dart`.
/// `stesa_tre_carte_screen.dart` non compariva in nessuno dei quattro, quindi
/// una stesa completata non registrava niente e nessun traguardo dei tarocchi
/// poteva accendersi, ne' con tre stese ne' con trecento. Il Cosmic Passport,
/// che si credeva collegato, non lo era.
///
/// **Perche' questa prova e non un controllo sui tarocchi.** Se e' successo
/// ai tarocchi e' successo altrove: un controllo sulla sola stesa avrebbe
/// chiuso un caso e lasciato aperta la famiglia. Questa enumera i gesti
/// nominati dai 165 traguardi, risale alla schermata che deve mandarli, legge
/// il sorgente e CADE COL NOME DEL FILE.
void main() {
  /// Tutti i gesti che i 165 traguardi nominano, presi dalle condizioni e non
  /// da un elenco scritto a mano: un elenco a mano invecchia, le condizioni no.
  Set<String> gestiNominati() {
    final dentro = <String>{};
    final sorgenti = [
      for (final nome in const [
        'sentiero_costellazione.dart',
        'sentiero_albero.dart',
        'sentiero_loto.dart',
      ])
        File('lib/core/sigilli/$nome').readAsStringSync(),
    ].join('\n');

    for (final schema in [
      RegExp(r"GestiCompiuti\('([a-z_]+)'"),
      RegExp(r"GestoNellOraGiusta\('([a-z_]+)'"),
      RegExp(r"GestoDelCerchio\('([a-z_]+)'"),
      RegExp(r"GiorniDiSeguito\('([a-z_]+)'"),
      // **ANCHE LE COSTANZE A FINESTRA, ordine AU voce 03.** La revisione D2
      // ha portato le ultime costanze da `GiorniDiSeguito` a
      // `GiorniDentroUnArco`, e questo elenco non conosceva la seconda forma:
      // il gesto "presenza" spariva dai nominati e la prova accusava il
      // registro di dichiarare un gesto che nessuno usa piu'. Lo usano
      // eccome: e' scritto in un costruttore che questa riga non guardava.
      RegExp(r"GiorniDentroUnArco\('([a-z_]+)'"),
      RegExp(r"PezzoDellIdentita\('([a-z_]+)'\)"),
      RegExp(r"conGesto: '([a-z_]+)'"),
    ]) {
      for (final trovato in schema.allMatches(sorgenti)) {
        dentro.add(trovato.group(1)!);
      }
    }
    // I gesti elencati dentro GestiNelloStessoGiorno.
    for (final blocco
        in RegExp(r'GestiNelloStessoGiorno\(\[([^\]]*)\]').allMatches(sorgenti)) {
      for (final voce in RegExp(r"'([a-z_]+)'").allMatches(blocco.group(1)!)) {
        dentro.add(voce.group(1)!);
      }
    }
    return dentro;
  }

  test('il registro dei gesti copre tutti i gesti dei 165 traguardi', () {
    final nominati = gestiNominati();
    expect(nominati, isNotEmpty,
        reason: 'nessun gesto trovato nei tre sentieri: e\' la prova a essere '
            'rotta, non il codice');
    final fuoriRegistro = [
      for (final gesto in nominati)
        if (GestiDelleArti.di(gesto) == null) gesto,
    ]..sort();
    expect(fuoriRegistro, isEmpty,
        reason: 'questi gesti li nominano i traguardi e nessuno dichiara chi '
            'debba mandarli: $fuoriRegistro. Un gesto senza sorgente e\' un '
            'traguardo che nessuno potra\' mai accendere, ed e\' esattamente '
            'com\'era la stesa');

    // E il contrario: un registro che nomina gesti che nessun traguardo usa
    // e' un registro che invecchia in silenzio.
    final inutili = [
      for (final s in GestiDelleArti.tutte)
        if (!nominati.contains(s.gesto)) s.gesto,
    ]..sort();
    expect(inutili, isEmpty,
        reason: 'il registro dichiara gesti che nessun traguardo nomina piu\': '
            '$inutili');
  });

  test('ogni arte che ha una schermata manda il suo gesto alla regia', () {
    final scollegate = <String>[];
    for (final sorgente in GestiDelleArti.conSchermata) {
      final file = File(sorgente.schermata!);
      if (!file.existsSync()) {
        scollegate.add('${sorgente.schermata}  (il file non esiste piu\')');
        continue;
      }
      final codice = file.readAsStringSync();
      final chiama = codice.contains('RegiaDelCammino.dopoUnGesto');
      final colGesto = RegExp(
              "dopoUnGesto\\([^;]*'${RegExp.escape(sorgente.gesto)}'")
          .hasMatch(codice);
      if (!chiama || !colGesto) {
        scollegate.add('${sorgente.schermata}  '
            '(compie il gesto "${sorgente.gesto}" e '
            '${chiama ? "chiama la regia con un altro gesto" : "non chiama "
                "mai RegiaDelCammino.dopoUnGesto"})');
      }
    }
    expect(scollegate, isEmpty,
        reason: 'queste arti compiono un gesto del cammino e non lo mandano '
            'alla regia, quindi i loro traguardi non si accenderanno mai:\n'
            '${scollegate.join("\n")}');
  });

  test('i gesti senza schermata sono dichiarati, non dimenticati', () {
    // Non fa cadere niente: e' la voce del rapporto. Un dato mancante si
    // dichiara con la sua ragione, e il traguardo resta visibile e non ancora
    // raggiungibile, come prescrive l'Allegato A.
    for (final s in GestiDelleArti.senzaSchermata) {
      expect(s.perche, isNotNull,
          reason: 'il gesto "${s.gesto}" non ha una schermata e nemmeno una '
              'ragione dichiarata: un dato mancante senza ragione e\' un dato '
              'dimenticato');
      expect(s.perche!.trim(), isNotEmpty);
    }
    // ignore: avoid_print
    print('ARTI SENZA SCHERMATA, da riportare nel rapporto: '
        '${GestiDelleArti.senzaSchermata.map((s) => s.gesto).join(", ")}');
  });

  test('la regia alimenta davvero la fotografia del cammino', () {
    // La famiglia della stesa scollegata non era fatta solo di schermate: due
    // INGRESSI della fotografia erano murati nella regia stessa.
    // Si guarda il CODICE, non i commenti: la spiegazione del difetto nomina
    // per forza `seriePerRito: const {}`, e accusare il commento che racconta
    // il difetto vorrebbe dire cancellare la memoria di com'era nato.
    final regia = File('lib/features/sigilli/regia_del_cammino.dart')
        .readAsLinesSync()
        .where((r) =>
            !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
        .join('\n');
    expect(regia.contains('seriePerRito: const {}'), isFalse,
        reason: 'la regia passa di nuovo una serie VUOTA: tutti i traguardi '
            'GiorniDiSeguito tornerebbero irraggiungibili, i cinque dell\'alba, '
            'i cinque dell\'oracolo e i cinque del tramonto');
    expect(regia.contains('pezziDellIdentita:'), isTrue,
        reason: 'la regia non passa i pezzi dell\'identita\': senza, nemmeno i '
            'TRE Sigilli di aggancio trasversali possono accendersi, e sono i '
            'primi tre traguardi che una persona incontra');

    // **LA RIGA PRETENDEVA TRE TRASVERSALI, E ADESSO SONO ZERO.** Ordine U voce
    // 01: quei tre non erano una decisione ma un difetto, un gesto solo li
    // accendeva tutti e tre e pagava sessanta Eos. Non si allenta cio' che
    // chiedeva: si sposta su cio' che resta vero, cioe' che OGNI ripetizione
    // dichiarata sia alimentata da una schermata vera. Con l'elenco vuoto la
    // riga non guarda niente, e lo DICE invece di passare in silenzio.
    final trasversali = Sentieri.agganciTrasversali;
    // ignore: avoid_print
    print('ORDINE U VOCE 01: ripetizioni dichiarate ${trasversali.length}');
    for (final firma in trasversali) {
      final pezzo = firma.split(':').last;
      expect(GestiDelleArti.di(pezzo)?.costruito, isTrue,
          reason: 'il Sigillo di aggancio trasversale "$pezzo" non ha una '
              'schermata che lo mandi: e\' uno dei tre che si accendono da '
              'qualunque sentiero, e nessuno lo alimenta');
    }
  });
}
