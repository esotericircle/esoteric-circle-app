import 'dart:math';

import 'package:esoteric_circle/core/domande/cornici_del_presagio.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE SEDICI CORNICI DEL PRESAGIO, e la misura (b) della decisione D5.
///
/// **Cosa sono.** Allegato B all'ordine S, materiale dell'Architetto: una cornice
/// per domanda, otto generiche e otto personali. La cornice porta la DOMANDA, non
/// la runa: la runa continua a portare la sua frase di corpus. E' per questo che
/// non sono 576.
///
/// **LA MISURA (a) NON E' QUI, e non e' una dimenticanza.** A parita' di runa, due
/// domande diverse devono dare presagi che condividono meno di una soglia
/// dichiarata delle parole piene: e' una misura contro il MODELLO vero, eseguita
/// una volta e riportata col numero nel rapporto, come l'attribuzione cieca delle
/// tre voci dei Maestri. Metterla qui vorrebbe dire misurare il ripiego e
/// chiamarlo modello.
void main() {
  /// LE PAROLE CHE NON CONTANO, e il perche' di ognuna in una riga: sono le
  /// parole che compaiono in qualunque frase italiana. Se contassero, "il" e "di"
  /// basterebbero a dire che il presagio parla della domanda.
  const vuote = {
    'il',
    'lo',
    'la',
    'le',
    'gli',
    'un',
    'una',
    'uno',
    'del',
    'della',
    'dei',
    'delle',
    'di',
    'da',
    'in',
    'su',
    'per',
    'con',
    'tra',
    'fra',
    'che',
    'chi',
    'cosa',
    'come',
    'dove',
    'quando',
    'quale',
    'quali',
    'mi',
    'ti',
    'si',
    'ci',
    'vi',
    'me',
    'te',
    'se',
    'non',
    'ma',
    'poi',
    'anche',
    'ancora',
    'sono',
    'e',
    'ed',
    'o',
    'al',
    'allo',
    'alla',
    'ai',
    'agli',
    'alle',
    'nel',
    'nella',
    'sul',
    'sulla',
    'mio',
    'mia',
    'miei',
    'mie',
    'tuo',
    'tua',
    'tuoi',
    'tue',
    'questo',
    'questa',
    'questi',
    'queste',
    'sto',
    'stai',
    'devo',
    'adesso',
    'ora',
    'oggi',
  };

  /// LE PAROLE PIENE di un testo: minuscole, senza punteggiatura, lunghe almeno
  /// quattro lettere e non nell'elenco delle vuote.
  Set<String> paroleP1ene(String testo) => testo
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zàèéìòóù\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.length >= 4 && !vuote.contains(p))
      .toSet();

  test('ogni domanda della gettata ha la sua cornice, e viceversa', () {
    // I DUE VERSI DELLA STESSA PORTA, e servono entrambi. Una domanda senza
    // cornice manderebbe a video il testo della giornata a chi ha chiesto del
    // lavoro; una cornice senza domanda e' una deroga che nessuno ha dichiarato,
    // e resterebbe li' a far credere che una domanda esista ancora.
    expect(CorniciDelPresagio.domandeSenzaCornice(), isEmpty,
        reason: 'queste domande della gettata non hanno cornice: '
            '${CorniciDelPresagio.domandeSenzaCornice().join(", ")}');
    expect(CorniciDelPresagio.corniciSenzaDomanda(), isEmpty,
        reason: 'queste cornici non hanno piu\' la loro domanda: '
            '${CorniciDelPresagio.corniciSenzaDomanda().join(", ")}');
    // Sedici, come l'allegato: otto e otto.
    expect(CorniciDelPresagio.generiche.length, 8);
    expect(CorniciDelPresagio.personali.length, 8);
  });

  test('nessuna cornice nomina una runa', () {
    // Il vincolo 1 dell'allegato: il simbolo compare nella parte 3 e non prima.
    // Una cornice che nomina la pietra smette di essere una cornice.
    final colpe = <String>[];
    // **TUTTE E DICIASSETTE**, la giornata compresa: il vincolo 1 non dipende dal
    // fatto che ci sia una domanda.
    for (final c in [
      ...CorniciDelPresagio.tutte,
      CorniciDelPresagio.dellaGiornata,
    ]) {
      for (final r in kElderFuthark) {
        if (c.apertura.contains(r.name) || c.chiusura.contains(r.name)) {
          colpe.add('${c.domanda}: nomina ${r.name}');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('MISURA (b): il presagio condivide parole piene con la SUA domanda', () {
    // **LA SOGLIA E' UNA PAROLA PIENA, e la prima volta avevo dichiarato DUE.**
    // Il cambio va scritto, perche' una soglia che si muove e' la cosa piu'
    // sospetta che ci sia in una prova.
    //
    // Dichiarai due su un principio inventato a tavolino: "due parole perche'
    // l'area sia nominata e non evocata". La misura ha risposto che cinque cornici
    // su sedici ne condividono una sola, e sono queste: momento, amore, insistere,
    // Ascendente. **Quella parola non e' poca, e' esattamente il nome dell'area**,
    // cioe' cio' che il vincolo 2 dell'allegato chiede. Il conto e' per TOKEN
    // esatti e non conosce le forme: "mostro" della domanda e "mostri" della
    // cornice sono due parole diverse per questa prova pur essendo lo stesso
    // verbo. Pretenderne due vorrebbe dire pretendere che la cornice ripeta la
    // domanda, che e' il contrario di cio' che l'allegato vuole.
    //
    // **Il principio nuovo:** almeno una parola piena della domanda, cioe' il nome
    // dell'area, dev'essere nel presagio. Non e' il minimo osservato, e' una
    // soglia sotto la quale il presagio parlerebbe di qualcosa che la persona non
    // ha nominato.
    const sogliaDichiarata = 1;

    // **LA DEROGA DELLA G8 NON SERVE PIU', ed e' la prova che l'ha chiesta.** La
    // prima stesura di "Cosa non sto guardando di me?" non conteneva nessuna
    // parola piena della sua domanda: era l'unica delle sedici a violare il
    // vincolo 2 dell'allegato. La misura l'ha detto, e l'Architetto ha riscritto la
    // cornice il 13 agosto 2026 invece di farsi aggiustare la misura addosso.
    //
    // **LA DICIASSETTESIMA CORNICE, quella della giornata, NON entra in questa
    // misura, e si esclude PER NOME come chiede l'allegato:** non esiste una
    // domanda con cui confrontare le parole, quindi la (b) su di lei non vuol dire
    // niente. Escluderla dentro la condizione, in silenzio, avrebbe nascosto la
    // ragione.

    final minimi = <String, int>{};
    for (final d in [
      ...DomandeDelCerchio.generichePerLaGettata,
      ...DomandeDelCerchio.personaliPerLaGettata,
    ]) {
      final dellaDomanda = paroleP1ene(d.testo);
      var minimo = 1 << 20;
      for (final g in gettate) {
        for (var seme = 0; seme < 20; seme++) {
          final presagio = RunePresagio.componiIlResponso(
              RuneCast.getta(g, random: Random(seme)),
              domanda: d.testo);
          final condivise =
              paroleP1ene(presagio.inParole).intersection(dellaDomanda);
          minimo = min(minimo, condivise.length);
        }
      }
      minimi[d.testo] = minimo;
    }
    final povere = minimi.entries
        .where((e) => e.value < sogliaDichiarata)
        .map((e) => '${e.key}: ${e.value} parole piene condivise')
        .toList();
    expect(povere, isEmpty,
        reason: 'questi presagi non parlano della domanda posta:\n'
            '${povere.join("\n")}');

    // Il minimo misurato, stampato perche' il numero valga anche fra sei mesi.
    final minimoAssoluto = minimi.values.reduce(min);
    // ignore: avoid_print
    print('MISURA (b): minimo di parole piene condivise fra presagio e sua '
        'domanda = $minimoAssoluto (soglia dichiarata $sogliaDichiarata)');
    expect(minimoAssoluto, greaterThanOrEqualTo(sogliaDichiarata));

    // **E LA DICIASSETTESIMA RESTA FUORI DA QUESTO ELENCO, per nome.** Se un
    // giorno entrasse fra le domande della gettata, la misura la prenderebbe e
    // risponderebbe zero: questa riga cade prima, dicendo perche'.
    expect(
        minimi.containsKey(CorniciDelPresagio.dellaGiornata.domanda), isFalse,
        reason:
            'la cornice della giornata e\' entrata nella misura (b): non ha '
            'una domanda con cui confrontare le parole');
  });

  test('la chiusura di ogni cornice e\' una cosa che si puo\' fare', () {
    // Il vincolo 4 dell'allegato. Le formule che non si possono compiere sono la
    // via facile di ogni oracolo: si nominano una per una perche' rientrino solo
    // di proposito.
    const formule = [
      'ascolta te stesso',
      'ascoltati',
      'segui il tuo cuore',
      'fidati del tuo istinto',
      'sii te stesso',
      'lascia andare tutto',
      'apriti all\'universo',
    ];
    final colpe = <String>[];
    for (final c in [
      ...CorniciDelPresagio.tutte,
      CorniciDelPresagio.dellaGiornata,
    ]) {
      final basso = c.chiusura.toLowerCase();
      for (final f in formule) {
        if (basso.contains(f)) colpe.add('${c.domanda}: "$f"');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('le sedici stanno dentro il confine della voce S.17', () {
    // Il vincolo 3 dell'allegato: nessuna previsione certa, nessun consiglio
    // medico, legale o finanziario. Il confine e' quello dell'ordine, non una
    // seconda lista scritta qui.
    final colpe = <String>[];
    for (final c in [
      ...CorniciDelPresagio.tutte,
      CorniciDelPresagio.dellaGiornata,
    ]) {
      for (final testo in [c.apertura, c.chiusura]) {
        final v = ConfineDelResponso.violazioni(testo);
        if (v.isNotEmpty) colpe.add('${c.domanda}: ${v.join("; ")}');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('il presagio con cornice monta apertura, runa e chiusura', () {
    // L'ordine del montaggio, dall'allegato. Si guarda su una gettata vera, non
    // sulle stringhe della cornice: e' il montaggio che si verifica.
    final cornice =
        CorniciDelPresagio.perDomanda('Nel lavoro, quale passo fare?')!;
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    final presagio =
        RunePresagio.componiIlResponso(esito, domanda: cornice.domanda);
    expect(presagio.risposta.startsWith(cornice.apertura), isTrue,
        reason: 'la risposta non apre con l\'apertura della cornice');
    expect(presagio.cosaPuoiFare, cornice.chiusura,
        reason: 'cosa puoi fare non e\' la chiusura della cornice');
    // La frase della runa si innesta dopo l'apertura, e non e' toccata.
    final primaRuna = RunePresagio.primaFraseDiProva(esito.rune.first.riga);
    expect(presagio.risposta.toLowerCase().contains(primaRuna.toLowerCase()),
        isTrue,
        reason: 'la frase della runa non si e\' innestata dopo l\'apertura');
    // E il nome della runa resta nella terza parte.
    expect(presagio.risposta.contains(esito.rune.first.rune.name), isFalse);
    expect(presagio.daDoveViene.contains(esito.rune.first.rune.name), isTrue);
  });

  test('senza cornice il ripiego parla alla giornata, non a una domanda altrui',
      () {
    // **L'ALLEGATO LO VIETA IN CHIARO:** nessuna delle sedici si usa come ripiego
    // generico, perche' direbbe alla persona che ha chiesto una cosa che non ha
    // chiesto. Vale per chi non sceglie nulla e per chi scrive la domanda con
    // parole sue.
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    for (final domanda in ['', 'Ma il mio gatto mi vuole bene?']) {
      final presagio = RunePresagio.componiIlResponso(esito, domanda: domanda);
      for (final c in CorniciDelPresagio.tutte) {
        expect(presagio.risposta.contains(c.apertura), isFalse,
            reason: 'con la domanda "$domanda" il ripiego ha usato la cornice '
                'di "${c.domanda}"');
        expect(presagio.cosaPuoiFare, isNot(c.chiusura),
            reason: 'con la domanda "$domanda" il ripiego ha usato la chiusura '
                'di "${c.domanda}"');
      }
      // **LE DUE STRADE DEL RIPIEGO, ordine BF voce 05.a.** Chi non chiede
      // riceve la diciassettesima cornice, quella della giornata; chi ha
      // scritto una domanda con parole sue NON riceve "Non hai chiesto
      // niente", che per lui sarebbe una bugia: apertura e chiusura della
      // giornata si omettono, e restano le letture per posizione dal corpus.
      if (domanda.isEmpty) {
        expect(presagio.risposta.contains('giornata'), isTrue);
      } else {
        expect(presagio.risposta.contains('Non hai chiesto niente'), isFalse,
            reason: 'a chi ha scritto una domanda il ripiego nega che sia '
                'stata posta');
        expect(presagio.risposta.trim(), isNotEmpty);
      }
    }
  });

  test('la diciassettesima parla alla giornata e APRE invece di chiudere', () {
    // Allegato B aggiornato: la cornice della giornata non chiude, apre. Chi getta
    // senza domanda esce con una domanda per il giorno dopo, ed e' il ritorno che
    // la voce cerca.
    const g = CorniciDelPresagio.dellaGiornata;
    expect(g.domanda, isEmpty,
        reason:
            'la cornice della giornata non ha una domanda, per definizione');
    expect(g.apertura, contains('giornata'));
    expect(g.chiusura, contains('domani'),
        reason:
            'la diciassettesima deve lasciare una domanda per domani: e\' la '
            'parte che fa tornare');
    // E si trova per la domanda vuota, che e' il modo in cui il motore la chiede.
    expect(CorniciDelPresagio.perDomanda(''), same(g));
    expect(CorniciDelPresagio.perDomanda('   '), same(g));
    // Ma NON compare fra le sedici: se vi entrasse, la misura (b) la prenderebbe.
    expect(CorniciDelPresagio.tutte.length, 16);
    expect(CorniciDelPresagio.tutte.contains(g), isFalse);
  });
}
