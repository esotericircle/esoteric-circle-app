import 'dart:io';

import 'package:esoteric_circle/core/domande/cornici_del_presagio.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE DICIASSETTE CORNICI COINCIDONO CON LA FONTE, CARATTERE PER CARATTERE.
///
/// **Perche' questa prova esiste.** L'allegato B stava nel Progetto di Mauro e le
/// diciassette cornici sono state trascritte a mano nel codice. La regola "si usano
/// verbatim" non aveva nessuna guardia, e nello stesso commit una trascrizione ha
/// prodotto un "puu" al posto di un "puo'": non nelle cornici, nell'istruzione del
/// presagio, ma e' la stessa mano e lo stesso rischio. **Una regola senza una prova
/// e' un proposito.**
///
/// **LA FONTE E' `docs/responsi/cornici.md`**, l'allegato portato nel repository
/// senza toccarne un carattere. Non e' documentazione: e' il dato da cui il codice
/// deve coincidere. Se le due cose divergono, questa prova cade col nome della
/// cornice e mostra le due righe.
///
/// **LE TRE TRASFORMAZIONI DICHIARATE, e sono le uniche ammesse.** L'allegato usa
/// la convenzione ASCII dei documenti (`e'` per `è`) e porta le virgole prima della
/// "e" che l'ordine dice di togliere. Quindi il confronto non e' sul testo grezzo:
/// e' sul testo grezzo TRASFORMATO da tre regole scritte qui sotto, meccaniche e
/// reversibili. Qualunque altra differenza fa cadere la prova, ed e' il punto:
/// **una trasformazione in piu' sarebbe un modo di far coincidere due testi
/// diversi.**
void main() {
  /// 1. GLI ACCENTI. La tavola e' esplicita e non indovina: se nella fonte
  /// comparisse una parola tronca che non e' qui, la prova cade invece di
  /// tirare a indovinare quale accento volesse.
  const accenti = <String, String>{
    "com'e'": 'com’è',
    "cosi'": 'così',
    "perche'": 'perché',
    "accadra'": 'accadrà',
    "sara'": 'sarà',
    "meta'": 'metà',
    "puo'": 'può',
    "piu'": 'più',
    "cio'": 'ciò',
    "gia'": 'già',
    "e'": 'è',
  };

  /// Gli apostrofi VERI, quelli che restano apostrofi: articoli elisi, il "di'"
  /// dell'imperativo, "un'ora". Nel codice si scrivono col segno tipografico.
  final apostrofiVeri = RegExp(r"\b(l|un|d|c|all|dell|quell|nell|sull|di|po)'",
      caseSensitive: false);

  /// Le parole tronche non dichiarate: se ne resta una dopo la tavola, la fonte
  /// dice qualcosa che questa prova non sa tradurre, e tacere sarebbe peggio.
  final troncheIgnote = RegExp(r"[aeiou]'(?![a-zà-ù])", caseSensitive: false);

  String normalizza(String grezzo) {
    var t = grezzo;
    // 1. Gli accenti, dalla tavola, i piu' lunghi per primi cosi' "com'e'" non
    // viene mangiato da "e'".
    final chiavi = accenti.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final k in chiavi) {
      // **LE MAIUSCOLE SI TENGONO.** La prima stesura sostituiva senza guardare
      // il caso, e "È quello che si può" tornava "è quello che si può": la prova
      // accusava il codice di divergere dalla fonte per un difetto della prova.
      final maiuscola = k[0].toUpperCase() + k.substring(1);
      final valore = accenti[k]!;
      final valoreMaiuscolo = valore[0].toUpperCase() + valore.substring(1);
      t = t.replaceAll(
          RegExp('(?<![a-zà-ùA-ZÀ-Ù])${RegExp.escape(maiuscola)}'
              '(?![a-zà-ùA-ZÀ-Ù])'),
          valoreMaiuscolo);
      t = t.replaceAll(
          RegExp('(?<![a-zà-ùA-ZÀ-Ù])${RegExp.escape(k)}'
              '(?![a-zà-ùA-ZÀ-Ù])'),
          valore);
    }
    // 2. Gli apostrofi che restano apostrofi prendono il segno tipografico.
    t = t.replaceAllMapped(apostrofiVeri, (m) => '${m[1]}’');
    // 3. LA VIRGOLA PRIMA DELLA E, che l'ordine dice di togliere dove non e'
    // portante: nelle cornici non lo e' mai, e lo ha deciso Mauro il 13 agosto
    // 2026 negando la deroga che avevo chiesto.
    // `replaceAll` prende una stringa LETTERALE, non un modello di sostituzione:
    // scrivendo `r'$1'` la fonte si riempiva di dollari e uni. Serve la forma con
    // la funzione, e a dirlo e' stata questa prova al primo giro.
    t = t.replaceAllMapped(RegExp(r',(\s+ed?\s)'), (m) => m[1]!);
    // Le righe della fonte vanno a capo per stare in ottanta colonne: nel codice
    // sono una frase sola.
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Estrae dalla fonte le coppie apertura e chiusura, per titolo di sezione.
  Map<String, ({String apertura, String chiusura})> leggiLaFonte() {
    final testo = File('docs/responsi/cornici.md').readAsStringSync();
    final fuori = <String, ({String apertura, String chiusura})>{};
    // Le sezioni cominciano con "## ": si spezza su di loro e si guarda dentro.
    final sezioni = testo.split(RegExp(r'^## ', multiLine: true));
    for (final sezione in sezioni.skip(1)) {
      final titolo = sezione.split('\n').first.trim();
      String? pezzo(String etichetta) {
        final i = sezione.indexOf('**$etichetta.**');
        if (i < 0) return null;
        final dopo = i + '**$etichetta.**'.length;
        // Il paragrafo finisce alla prima riga vuota.
        final fine = sezione.indexOf('\n\n', dopo);
        return sezione.substring(dopo, fine < 0 ? sezione.length : fine);
      }

      final a = pezzo('Apertura');
      final c = pezzo('Chiusura');
      if (a == null || c == null) continue;
      fuori[titolo] = (apertura: normalizza(a), chiusura: normalizza(c));
    }
    return fuori;
  }

  test('la fonte esiste e porta diciassette cornici', () {
    final fonte = leggiLaFonte();
    expect(File('docs/responsi/cornici.md').existsSync(), isTrue,
        reason: 'la fonte delle cornici non e\' nel repository: senza di lei '
            'questa prova non guarda niente');
    // Sedici piu' la diciassettesima: se la fonte ne perdesse una, il confronto
    // qui sotto non se ne accorgerebbe, perche' guarda il codice e cerca la sua
    // riga nella fonte.
    expect(fonte.length, 17,
        reason: 'nella fonte ci sono ${fonte.length} cornici invece di '
            'diciassette: ${fonte.keys.join(" | ")}');
  });

  test('nessuna parola tronca sfugge alla tavola degli accenti', () {
    // **IL PRESIDIO DELLA TRASFORMAZIONE.** Se la fonte porta una parola tronca
    // che la tavola non conosce, la normalizzazione la lascerebbe con
    // l'apostrofo e il confronto cadrebbe dicendo "non coincide", che e' vero ma
    // non e' il motivo. Questa prova dice il motivo giusto.
    final fonte = leggiLaFonte();
    final ignote = <String>[];
    for (final voce in fonte.entries) {
      for (final testo in [voce.value.apertura, voce.value.chiusura]) {
        final m = troncheIgnote.firstMatch(testo);
        if (m != null) {
          ignote.add('${voce.key}: "${m[0]}" in "$testo"');
        }
      }
    }
    expect(ignote, isEmpty,
        reason: 'la fonte usa parole tronche che la tavola degli accenti non '
            'conosce, quindi la prova non sa tradurle:\n${ignote.join("\n")}');
  });

  test('ogni cornice del codice coincide con la sua riga nella fonte', () {
    final fonte = leggiLaFonte();
    // Il titolo di sezione porta la domanda fra virgolette: e' la chiave con cui
    // si ritrova la cornice, e per la diciassettesima e' l'unica sezione che
    // comincia per "LA DICIASSETTESIMA".
    String? titoloPer(String domanda) {
      if (domanda.isEmpty) {
        return fonte.keys.firstWhere((k) => k.startsWith('LA DICIASSETTESIMA'),
            orElse: () => '');
      }
      return fonte.keys.firstWhere((k) => k.contains('"$domanda"'),
          orElse: () => '');
    }

    final divergenze = <String>[];
    final tutte = [
      ...CorniciDelPresagio.tutte,
      CorniciDelPresagio.dellaGiornata,
    ];
    for (final c in tutte) {
      final titolo = titoloPer(c.domanda);
      if (titolo == null || titolo.isEmpty) {
        divergenze.add('la cornice "${c.domanda}" non ha una sezione nella '
            'fonte');
        continue;
      }
      final dallaFonte = fonte[titolo]!;
      if (c.apertura != dallaFonte.apertura) {
        divergenze.add('$titolo, APERTURA\n'
            '  codice: ${c.apertura}\n'
            '  fonte : ${dallaFonte.apertura}');
      }
      if (c.chiusura != dallaFonte.chiusura) {
        divergenze.add('$titolo, CHIUSURA\n'
            '  codice: ${c.chiusura}\n'
            '  fonte : ${dallaFonte.chiusura}');
      }
    }
    expect(divergenze, isEmpty,
        reason: 'il codice non coincide con la fonte `docs/responsi/cornici.md`. '
            'Le cornici sono materiale dell\'Architetto e si usano verbatim: '
            'quando divergono ha ragione la fonte.\n\n'
            '${divergenze.join("\n\n")}');
    // E ogni sezione della fonte ha trovato la sua cornice nel codice: cosi' una
    // cornice dimenticata nella trascrizione non passa inosservata.
    expect(tutte.length, fonte.length);
  });
}
