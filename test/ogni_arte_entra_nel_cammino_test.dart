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
  /// Tutti i gesti che i 165 traguardi nominano, **chiesti alle condizioni**.
  ///
  /// **Qui c'era un elenco di espressioni regolari, uno schema per specie di
  /// condizione, e leggeva i tre file dei sentieri come testo.** Ordine CP
  /// voce 05: quell'elenco era cieco su ogni specie nuova. Era gia' successo
  /// nell'ordine AU con `GiorniDentroUnArco`, ed e' successo di nuovo con
  /// `GiornateInsieme`, che nomina fino a sei gesti per gradino: sarebbero
  /// spariti dai nominati e la prova sarebbe stata verde senza averli
  /// guardati.
  ///
  /// Adesso la domanda si fa all'oggetto, che sa rispondere per costruzione:
  /// **una specie nuova che non risponde non compila**, invece di tacere.
  Set<String> gestiNominati() => {
        for (final t in Sentieri.tuttiITraguardi) ...t.condizione.gestiNominati,
      };

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
    // **TRE GESTI RESTANO NEL REGISTRO SENZA UN TRAGUARDO CHE LI NOMINI, e si
    // dichiarano invece di sparire.** Ordine BS voce 01. Il registro censisce
    // cio' che l'app MANDA; il corpus decide su cosa costruire un gradino, e
    // la revisione E ha fatto scelte sue. Toglierli dal registro sarebbe la
    // cosa sbagliata: un gesto che l'app manda e nessuno censisce e' proprio
    // il difetto che questa prova esiste per impedire.
    // **L'ELENCO SEGUE IL DATO, ordine CP voce 05.** La revisione F sceglie
    // venti gesti su cui costruire i 165, tutti con una schermata che li
    // manda. Gli altri restano censiti perche\' l'app li manda davvero: il
    // registro censisce cio\' che l'app manda, il corpus decide su cosa
    // costruire un gradino, e le due domande sono diverse.
    const dichiaratiSenzaTraguardo = <String, String>{
      'presenza': 'nessun gradino dice piu\' "sette giorni di presenza": le '
          'costanze stanno sulle arti. Il guscio continua a mandarla e il '
          'diario a contarla, perche\' e\' la serie su cui poggia il ritorno.',
      'ora_di_nascita': 'e\' una tessera del Passaporto, non un\'arte: il '
          'Cammino la incontra dentro la carta natale.',
      'luogo_di_nascita': 'come l\'ora di nascita, e\' una tessera del '
          'documento e non un rito che si ripete.',
      'numero_della_vita': 'e\' una tessera del Passaporto, calcolata una '
          'volta dalla data: non c\'e\' niente da ripetere.',
      'passaporto': 'aprire il documento non e\' un\'arte: il gradino '
          'dell\'identita\' e\' la carta natale, che il documento mostra.',
      'nome_proprio': 'il saluto per nome e\' un fatto del Santuario, non un '
          'rito: nessun gradino lo chiede.',
      'sigillo_del_cerchio': 'e\' una tessera deterministica del Passaporto, '
          'viva dalla sola data di nascita.',
      'luna_natale': 'come il Sigillo del Cerchio, e\' deterministica: non '
          'c\'e\' un gesto da contare.',
      'nascita_completa': 'e\' un pezzo COMPOSTO, non un gesto: la revisione '
          'F preferisce nominare la carta natale, che e\' la cosa che la '
          'persona riconosce.',
      'condivisione_stella': 'la condivisione e\' premio, mai pedaggio: la '
          'revisione F non costruisce gradini su di lei.',
      'condivisione_frutto': 'come la condivisione della Stella.',
      'condivisione_petalo': 'come la condivisione della Stella.',
      'invito_medora': 'un invito non si puo\' chiedere: dipende da un\'altra '
          'persona, e un gradino che dipende da altri non e\' raggiungibile '
          'da chi cammina.',
      'invito_aura': 'come l\'invito a Medora.',
      'invito_caligo': 'come l\'invito a Medora.',
    };
    final inutili = [
      for (final s in GestiDelleArti.tutte)
        if (!nominati.contains(s.gesto) &&
            !dichiaratiSenzaTraguardo.containsKey(s.gesto))
          s.gesto,
    ]..sort();
    // ignore: avoid_print
    print('ORDINE BS VOCE 01: gesti censiti senza un traguardo che li nomini, '
        'dichiarati ${dichiaratiSenzaTraguardo.keys.toList()..sort()}');
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
      final colGesto =
          RegExp("dopoUnGesto\\([^;]*'${RegExp.escape(sorgente.gesto)}'")
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
    const trasversali = Sentieri.agganciTrasversali;
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
