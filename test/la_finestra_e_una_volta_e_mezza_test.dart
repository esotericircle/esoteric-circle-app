import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA FINESTRA VALE UNA VOLTA E MEZZA. Ordine AU voce 03.
///
/// **Il difetto che questa guardia esiste per impedire, e che e' gia'
/// successo.** La revisione D del corpus ha portato ventidue gradini di
/// costanza dai giorni consecutivi ai giorni dentro un arco. La conversione
/// era automatica e ha messo nell'arco il numero sbagliato: sono usciti
/// gradini che chiedevano **quattordici giorni di presenza dentro un arco di
/// tre**, cioe' condizioni che non possono maturare mai, e sette di loro sono
/// stati dichiarati dormienti per un difetto di aritmetica invece che per una
/// funzione mancante.
///
/// **Perche' una guardia e non solo la correzione.** Il difetto e' nato da una
/// conversione a macchina, e le conversioni a macchina si rifanno. Senza
/// qualcuno che conti, la prossima revisione lo rimette dentro e ce ne
/// accorgiamo fra sei mesi da un utente che non avanza.
///
/// **Tre cose si pretendono, e sono quelle che l'ordine detta:**
/// 1. nessun gradino chiede piu' giorni di quanti ne concede il suo arco;
/// 2. nessuna condizione dice "consecutiv";
/// 3. nessun nome promette "di seguito" mentre la condizione e' a finestra,
///    perche' chi legge un nome che promette due sere DI SEGUITO e poi ne
///    salta una crede di aver perso un gradino che invece ha ancora.
void main() {
  final corpus = File('docs/corpus/Traguardi_165_Revisione_E.json');

  /// **LA LEGGE, ripetuta qui apposta.** Sta anche nel corpus e nel generatore,
  /// e qui non si importa da nessuno dei due: una guardia che legge la regola
  /// dallo stesso posto che sorveglia non sorveglia niente.
  const legge = <int, int>{
    2: 3, 3: 5, 5: 8, 7: 10, 14: 20, 21: 30, 30: 45, 40: 60, 60: 85, 90: 130,
  };

  List<Map<String, dynamic>> tutteLeVoci() {
    final dato = jsonDecode(corpus.readAsStringSync()) as Map<String, dynamic>;
    return [
      for (final s in dato['sentieri'] as List)
        for (final v in (s as Map)['voci'] as List) v as Map<String, dynamic>,
    ];
  }

  /// **I NUMERI SCRITTI IN LETTERE, e non e' un dettaglio.** Il corpus scrive
  /// "Tre Oracoli del Giorno, nell'arco di 5 giorni": il primo numero e' una
  /// PAROLA e il secondo una cifra. La prima stesura di questa guardia cercava
  /// due cifre, ne trovava una sola e lasciava perdere la voce: era verde su
  /// tutte e centosessantacinque perche' non ne guardava nessuna. Verde per
  /// non aver guardato e' il modo piu' comodo di non accorgersi di niente.
  const parole = <String, int>{
    'un': 1, 'una': 1, 'due': 2, 'tre': 3, 'quattro': 4, 'cinque': 5,
    'sei': 6, 'sette': 7, 'otto': 8, 'nove': 9, 'dieci': 10, 'undici': 11,
    'dodici': 12, 'tredici': 13, 'quattordici': 14, 'quindici': 15,
    'venti': 20, 'ventuno': 21, 'trenta': 30, 'quaranta': 40,
    'cinquanta': 50, 'sessanta': 60, 'settanta': 70, 'ottanta': 80,
    'novanta': 90, 'cento': 100,
  };

  /// I due numeri di una condizione a finestra: quanti giorni e quanto e' largo
  /// l'arco. Torna null se la condizione non e' a finestra.
  (int, int)? finestraDi(String condizione) {
    if (!condizione.contains("nell'arco di")) return null;
    final testa = condizione.split("nell'arco di").first.toLowerCase();
    final coda = condizione.split("nell'arco di").last;
    // L'arco e' sempre una cifra, e sta dopo le parole "nell'arco di".
    final cifra = RegExp(r'\d+').firstMatch(coda);
    if (cifra == null) return null;
    final arco = int.parse(cifra.group(0)!);
    // Quanti giorni: o una cifra prima dell'arco, o una parola-numero.
    final cifraTesta = RegExp(r'\d+').firstMatch(testa);
    if (cifraTesta != null) return (int.parse(cifraTesta.group(0)!), arco);
    for (final voce in parole.entries) {
      // Confine di parola in stringa GREZZA: uno '\b' dentro una stringa
      // normale di Dart non e' un confine di parola, e' il carattere di
      // ritorno indietro, e un regex che lo contiene non trova mai niente.
      if (RegExp(r'\b' + voce.key + r'\b').hasMatch(testa)) {
        return (voce.value, arco);
      }
    }
    return null;
  }

  test('il corpus D2 esiste ed e la revisione viva', () {
    expect(corpus.existsSync(), isTrue,
        reason: 'docs/corpus/Traguardi_165_Revisione_E.json non esiste. Lo '
            'scrive tool/genera_corpus_d2.py, non arriva da fuori');
    final dato = jsonDecode(corpus.readAsStringSync()) as Map<String, dynamic>;
    expect(dato['revisione'], 'E');
    // **LA REVISIONE E NON PORTA PIU' LA LEGGE SCRITTA NEL CORPUS**, ordine BS
    // voce 01: la D2 la portava perche' quasi tutte le sue costanze erano
    // "nell'arco di N giorni" e la legge governava il dato; la E scrive le
    // costanze in altro modo e ne lascia quattro a finestra. Se il corpus la
    // dichiara deve dire il vero; se non la dichiara, la legge vive nel
    // generatore e in questa prova, e l'aritmetica qui sotto la sorveglia lo
    // stesso su ogni voce.
    final leggeNelCorpus = dato['legge_della_finestra'];
    if (leggeNelCorpus != null) {
      expect(leggeNelCorpus, isA<Map<String, dynamic>>());
    }
    final voci = tutteLeVoci();
    expect(voci, hasLength(165));
    final eos = voci.fold<int>(0, (a, v) => a + (v['eos'] as int));
    // ignore: avoid_print
    print('ORDINE AU VOCE 03: ${voci.length} gradini, $eos Eos in tutto');
    expect(eos, 6030, reason: 'gli Eos non si toccano: 2.010 per sentiero');
  });

  test('nessun gradino chiede piu giorni di quanti ne concede il suo arco', () {
    final rotti = <String>[];
    var aFinestra = 0;
    for (final v in tutteLeVoci()) {
      final f = finestraDi(v['condizione'] as String);
      if (f == null) continue;
      aFinestra++;
      final (quanti, arco) = f;
      if (arco < quanti) {
        rotti.add('${v['id']} chiede $quanti giorni dentro $arco');
      }
    }
    // ignore: avoid_print
    print('ORDINE AU VOCE 03: condizioni a finestra $aFinestra, impossibili '
        '${rotti.length}');
    expect(rotti, isEmpty,
        reason: 'questi gradini non possono maturare mai: $rotti');
  });

  test('la finestra sta sulla scala della legge', () {
    // Non si pretende il valore esatto per numeri che la scala non nomina, ma
    // per quelli nominati l'arco DEVE essere quello: se no la scala e' una
    // decorazione.
    final fuori = <String>[];
    for (final v in tutteLeVoci()) {
      final f = finestraDi(v['condizione'] as String);
      if (f == null) continue;
      final (quanti, arco) = f;
      final atteso = legge[quanti];
      if (atteso != null && arco != atteso) {
        fuori.add('${v['id']}: $quanti in $arco invece che in $atteso');
      }
    }
    expect(fuori, isEmpty,
        reason: 'questi archi non seguono la legge della finestra: $fuori');
  });

  test('nessuna condizione chiede giorni consecutivi', () {
    final rotti = [
      for (final v in tutteLeVoci())
        if ((v['condizione'] as String).toLowerCase().contains('consecutiv'))
          '${v['id']}: ${v['condizione']}',
    ];
    expect(rotti, isEmpty,
        reason: 'la revisione D2 ha tolto i giorni consecutivi da tutto il '
            'corpus, e questi li rimettono: $rotti');
  });

  test('nessun nome promette di seguito su una condizione a finestra', () {
    // **E' IL DIFETTO PIU' SUBDOLO DEI TRE**, perche' non rompe niente: la
    // condizione e' giusta, il gradino matura, e il nome mente lo stesso. Chi
    // salta una sera legge un nome che promette giorni di fila e smette di
    // provarci.
    final bugiardi = <String>[];
    for (final v in tutteLeVoci()) {
      final nome = (v['nome'] as String).toLowerCase();
      if (!nome.contains('di seguito')) continue;
      final condizione = v['condizione'] as String;
      if (finestraDi(condizione) != null ||
          !condizione.toLowerCase().contains('consecutiv')) {
        bugiardi.add('${v['id']}: "${v['nome']}" per "$condizione"');
      }
    }
    expect(bugiardi, isEmpty,
        reason: 'questi nomi promettono giorni di fila su condizioni che non '
            'li chiedono: $bugiardi');
  });
}
