import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA SCENA PARLA BENE: CHIAMA L'ANIMALE, NON BALLA, NON SI ANNIDA, CHIUDE.**
/// Ordine DI voci 04, 05 e 06, 12 settembre 2026.
///
/// **I difetti, misurati dall'ordine sul testo vero.** L'animale era *"l'animale"*
/// e il Lupo e il Corvo davano scene identiche; *"Vi trovate al ponte. Trovi la
/// chiave"* passava dal plurale al singolare e ripeteva il verbo; *"Da dove
/// nasce: Quello che e' successo di la': Vi trovate"* annidava due volte i due
/// punti; e le chiusure dicevano quasi tutte di non capire.
///
/// **PERCHE' NON BASTA LEGGERE LE COSTANTI.** I difetti nascono dalla
/// **cucitura**: una forma pulita e un'apertura pulita facevano i due punti
/// annidati solo insieme. Questa guardia **compone** le scene e i responsi
/// con tutte le forme, tutti i gradi di nitidezza, tutte le dodici figure
/// dell'animale e la sagoma, e legge l'uscita come la legge la persona. E'
/// la lezione di casa: le prove sui fatti restano verdi sugli errori di
/// italiano, e cercare le parole gia' sbagliate dice la verita' su ieri.
void main() {
  /// Ogni scena che la persona puo' leggere, **composta dalla strada vera**:
  /// sessanta domande, i tre gradi di nitidezza, i dodici animali col nome e
  /// senza. Si passa da `ScenaSenzaModello.componi` e non si costruiscono le
  /// scene a mano, perche' e' la composizione a scegliere i gesti che un
  /// animale sa fare e a scartare le figure che si ripetono: una scena che
  /// la composizione non produce mai non la legge nessuno.
  ///
  /// **QUATTROMILA SEMI, E NON SESSANTA.** Il seme nasce dalla domanda, dal
  /// giorno e dalla discesa, non dall'animale: la prima stesura faceva
  /// sessanta domande per dodici animali, cioe' **sessanta scene diverse**
  /// ripetute, e col difetto dell'acqua ferma rimesso a mano restava verde.
  /// La coppia *l'acqua ferma* e *si ferma* esce una volta ogni duecento
  /// scene: con quattromila semi la si incontra.
  List<ScenaDelViaggio> tutteLeScene() {
    final scene = <ScenaDelViaggio>[];
    const nitidezze = [1.0, 0.5, 0.1];
    for (var i = 0; i < 4000; i++) {
      final a = AnimalCatalog.animals[i % AnimalCatalog.animals.length];
      scene.add(ScenaSenzaModello.componi(
        domanda: 'la domanda numero $i',
        giorno: DateTime(2026, 9, 1 + i % 28),
        nitidezza: nitidezze[(i ~/ 24) % 3],
        discesa: i % 7,
        animale: a,
        siPuoDire: (i ~/ 12).isEven,
      ));
    }
    return scene;
  }

  List<String> frasi(String testo) => testo
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();

  test('DI.04: l animale ha un nome, e il nome ha l articolo giusto', () {
    final scene = tutteLeScene();
    cardinaleMinimo(scene.length, 2000,
        cosa: 'scene composte',
        perche: 'Con poche scene le forme che nominano l animale una volta sola '
            'potrebbero non uscire mai.');
    final colpevoli = <String>[];
    for (final s in scene) {
      for (final t in [s.testo, s.testoSenzaApertura]) {
        if (RegExp(r"\b[Ll]'animale\b").hasMatch(t)) {
          colpevoli.add('parola generica: $t');
        }
        // Il nome nudo, perche' dopo una preposizione l'articolo si fonde:
        // *insieme al Corvo*.
        final nome = s.chi.conArticolo.split(RegExp(r"[ ']")).last;
        if (!t.contains(nome)) colpevoli.add('senza nome: $t');
        if (RegExp(r"\b(il|la|lo) (Aquila|Orso)\b|\bil (Lince|Volpe|Tartaruga)"
                r"\b|\bla (Lupo|Corvo|Falco|Gufo|Cervo|Cavallo|Serpente)\b")
            .hasMatch(t)) {
          colpevoli.add('articolo sbagliato: $t');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 04: scene lette ${scene.length * 2}, difetti '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty, reason: colpevoli.take(6).join('\n'));

    // **IL LUPO E IL CORVO NON DANNO PIU LA STESSA SCENA.**
    ScenaDelViaggio con(String nome) => ScenaDelViaggio(
          luogo: VocabolarioDelViaggio.luoghi.first,
          cosa: VocabolarioDelViaggio.cose.first,
          gesto: VocabolarioDelViaggio.gesti.first,
          momento: VocabolarioDelViaggio.momenti.first,
          nitidezza: 1,
          chi: ChiAccompagna.animale(
              AnimalCatalog.animals.firstWhere((a) => a.name == nome)),
        );
    expect(con('Lupo').testo, isNot(con('Corvo').testo),
        reason: 'il Lupo e il Corvo producono la stessa scena parola per '
            'parola');
  });

  test('DI.04: nessun animale fa un gesto che il suo corpo non sa fare', () {
    final sbagliati = <String>[];
    for (final a in AnimalCatalog.animals) {
      for (var d = 0; d < 400; d++) {
        final s = ScenaSenzaModello.componi(
          domanda: 'domanda $d',
          giorno: DateTime(2026, 9, 12),
          nitidezza: 1,
          discesa: d,
          animale: a,
          siPuoDire: true,
        );
        final no = GestiDellAnimale.nonGliAppartengono[a.name] ?? const {};
        if (no.contains(s.gesto.id)) sbagliati.add('${a.name} ${s.gesto.nome}');
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 04: gesti impossibili su 4800 scene composte '
        '${sbagliati.length}');
    expect(sbagliati, isEmpty, reason: sbagliati.take(6).join(', '));
    expect(GestiDellAnimale.di('Aquila').map((g) => g.id),
        isNot(contains('mostra_i_denti')));
  });

  test('DI.04: prima del riconoscimento il nome non si dice', () {
    final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
    final prima = ScenaSenzaModello.componi(
        domanda: 'x', giorno: DateTime(2026, 9, 12), nitidezza: 1,
        animale: lupo, siPuoDire: false);
    final dopo = ScenaSenzaModello.componi(
        domanda: 'x', giorno: DateTime(2026, 9, 12), nitidezza: 1,
        animale: lupo, siPuoDire: true);
    expect(prima.testo.contains('Lupo'), isFalse,
        reason: 'la scena dice il nome prima della quarta discesa: '
            '${prima.testo}');
    expect(dopo.testo.contains('Lupo'), isTrue,
        reason: 'riconosciuto l animale, la scena non lo chiama per nome: '
            '${dopo.testo}');
  });

  /// **NESSUN TITOLO CONTIENE I DUE PUNTI**, ordine DK voce 01: il titolo e'
  /// l'unico pezzo che puo' finire concatenato ad altro, ed e' cosi' che
  /// nasceva la frase spezzata riparata nella voce DI.05. Si leggono tutti,
  /// quelli dei sei temi e quelli senza domanda, e nessun segno di
  /// punteggiatura interna che apra una spiegazione.
  test('DK.01: nessun titolo del responso contiene i due punti', () {
    final titoli = [
      for (final t in LaVoceDelMondoDiSotto.titoliPerTema.values) ...t,
      ...LaVoceDelMondoDiSotto.titoliSenzaDomanda,
    ];
    cardinaleMinimo(titoli.length, 148,
        cosa: 'titoli del responso',
        perche: 'Su un elenco vuoto nessun titolo avrebbe i due punti.');
    final coiDuePunti = titoli.where((t) => t.contains(':')).toList();
    // ignore: avoid_print
    print('ORDINE DK VOCE 01: titoli letti ${titoli.length}, coi due punti '
        '${coiDuePunti.length}');
    expect(coiDuePunti, isEmpty, reason: '$coiDuePunti');
  });

  /// **UN POSTO VUOL DIRE LA STESSA COSA IN OGNI GRADO**, ordine DJ voce 06:
  /// la voce del Mondo di Sotto sceglie la forma per posto, forma piu'
  /// quante forme per la chiusura, e con elenchi lunghi diversi lo stesso
  /// posto darebbe chiusure diverse secondo la nitidezza.
  test('DJ.06: i tre gradi hanno lo stesso numero di forme, ed e quello che '
      'la voce usa', () {
    expect(ScenaDelViaggio.formeVelate.length, ScenaDelViaggio.quanteForme);
    expect(ScenaDelViaggio.formeConfuse.length, ScenaDelViaggio.quanteForme);
    expect(ScenaDelViaggio.quanteForme, 16);
  });

  test('DI.05: seconda persona singolare, e il plurale solo col compagno '
      'nella stessa frase', () {
    final colpevoli = <String>[];
    for (final s in tutteLeScene()) {
      for (final f in frasi(s.testo)) {
        final plurale =
            RegExp(r'\b(siete|vi|voi|trovate|andate)\b', caseSensitive: false)
                .hasMatch(f);
        if (plurale && !f.startsWith('Tu e ')) colpevoli.add(f);
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 05: frasi al plurale senza compagno '
        '${colpevoli.length}');
    expect(colpevoli.toSet(), isEmpty,
        reason: colpevoli.toSet().take(6).join('\n'));
  });

  /// **ALLARGATA CON L'ORDINE DI VOCE 16**, 13 settembre 2026. Qui c'era un
  /// elenco chiuso di sei participi, *sceso, arrivato, andato, tornato,
  /// salito, stato*, e quattro elenchi della voce non si guardavano affatto:
  /// la prova a cento discese ha trovato *"Non sei bloccato"* fra le risposte
  /// del blocco e *"saresti pronto?"* fra quelle dell'attesa, e questa guardia
  /// era verde. Un elenco chiuso dice la verita' su ieri. Adesso si cerca la
  /// forma del difetto: dopo *sei, eri, saresti, sarai, fossi* qualunque
  /// participio o aggettivo al maschile, tranne quando si accorda col pronome
  /// oggetto, *te lo sei portato*, che e' italiano giusto e non dice niente di
  /// chi legge.
  test('DI.05: nessun participio al maschile riferito a chi legge', () {
    final materiale = <String>[
      ...ScenaDelViaggio.aperture,
      ...ScenaDelViaggio.chiusure,
      ...ScenaDelViaggio.formeIntere,
      ...ScenaDelViaggio.formeVelate,
      ...ScenaDelViaggio.formeConfuse,
      ...IlRichiamoDelleScene.forme,
      ...LaVoceDelMondoDiSotto.riprendeLaDomanda,
      ...LaVoceDelMondoDiSotto.risposteSenzaDomanda,
      ...LaVoceDelMondoDiSotto.titoliSenzaDomanda,
      ...LaVoceDelMondoDiSotto.daDoveViene,
      for (final r in LaVoceDelMondoDiSotto.rispostePerTema.values) ...r,
      for (final r in LaVoceDelMondoDiSotto.titoliPerTema.values) ...r,
      ...LaVoceDelMondoDiSotto.codaDellaRisposta,
      ...LaVoceDelMondoDiSotto.apreIlGesto,
      ...LaVoceDelMondoDiSotto.cosaPuoiFare,
      ...LaVoceDelMondoDiSotto.quando,
    ];
    // **256 FRAMMENTI CONTATI il 13 settembre 2026**, con i quattro elenchi
    // aggiunti; il minimo lascia sei frammenti di margine.
    cardinaleMinimo(materiale.length, 250,
        cosa: 'frammenti della voce e della scena',
        perche: 'Su un elenco vuoto nessun participio sarebbe sbagliato.');
    final alMaschile = RegExp(
        r"(?<!\b(lo|la|li|le) |l')\b(sei|eri|saresti|sarai|fossi|"
        // **ANCHE ALL'INFINITO, ordine DJ voce 01.** Fra i titoli dell'ordine
        // c'era *"Non ti serve essere sicuro"*, e questa guardia era verde:
        // cercava il verbo coniugato e basta. L'aggettivo che dice chi legge
        // arriva anche dopo *essere*, *stare*, *restare*, *sentirti*.
        r'essere|esserne|stare|restare|rimanere|sentirti) '
        r'([a-zàèéìòù]+(ato|uto|ito|eso|esso|otto|sto|nto|lto|rto)|'
        r'pronto|solo|sicuro|stanco|contento|convinto|pentito|perso)\b',
        caseSensitive: false);
    final colpevoli = materiale.where(alMaschile.hasMatch).toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 05: frammenti riletti ${materiale.length}, con un '
        'participio riferito a chi legge ${colpevoli.length}');
    expect(colpevoli, isEmpty, reason: '$colpevoli');
  });

  test('DI.05: nessuna forma ripete un verbo, nemmeno col gesto dentro', () {
    // **La misura e' la parola piena**, da cinque lettere in su, che in
    // queste frasi corte e' quasi sempre il verbo: le parole brevi sono
    // articoli e preposizioni, e la loro ripetizione e' la lingua.
    final colpevoli = <String>{};
    for (final s in tutteLeScene()) {
      final testo = s.testoSenzaApertura;
      final corpo = testo.substring(0, testo.lastIndexOf('.', testo.length - 2) + 1);
      final parole = RegExp(r"[a-zàèéìòù]{5,}")
          .allMatches(corpo.toLowerCase())
          .map((m) => m.group(0)!)
          .toList();
      final viste = <String>{};
      for (final p in parole) {
        if (!viste.add(p) && !s.chi.conArticolo.toLowerCase().contains(p)) {
          colpevoli.add('"$p" in: $corpo');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 05: scene con una parola piena ripetuta '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty, reason: colpevoli.take(6).join('\n'));
  });

  test('DI.05: in nessun responso due punti dentro altri due punti', () {
    final colpevoli = <String>{};
    var responsi = 0;
    final temi = [...TemaDellaDomanda.values.map((t) => t.name), null];
    for (final s in tutteLeScene().take(1200)) {
      for (final tema in temi) {
        for (var giorno = 1; giorno <= 3; giorno++) {
          final righe = LaVoceDelMondoDiSotto.paragrafi(
            scena: s,
            temaDomanda: tema,
            temaInLettere:
                tema == null ? null : TemaDellaDomanda.daId(tema)!.inLettere,
            giornoDellaDiscesa: DateTime(2026, 9, giorno),
          );
          responsi++;
          for (final r in righe) {
            for (final f in frasi(r)) {
              if (':'.allMatches(f).length > 1) colpevoli.add(f);
            }
            // **DOPO I DUE PUNTI SI CONTINUA IN MINUSCOLO**, tranne il nome
            // dell'animale, che e' un nome proprio.
            for (final m in RegExp(r': ([A-ZÀÈÉÌÒÙ]\w*)').allMatches(r)) {
              final parola = m.group(1)!;
              if (!AnimalCatalog.animals.any((a) => a.name == parola)) {
                colpevoli.add('maiuscola dopo i due punti: $r');
              }
            }
          }
          // **IL GESTO NON RIPETE UNA PAROLA FRA L'APERTURA E IL QUANDO**:
          // *"Il passo di oggi: ... Oggi."*
          final quando = LaVoceDelMondoDiSotto.quando
              .firstWhere((q) => righe[1].endsWith(q));
          final prima = righe[1]
              .substring(0, righe[1].length - quando.length)
              .toLowerCase();
          for (final p in RegExp(r'[a-zàèéìòù]{4,}')
              .allMatches(quando.toLowerCase())) {
            if (RegExp('\\b${p.group(0)}\\b').hasMatch(prima)) {
              colpevoli.add('il quando ripete "${p.group(0)}": ${righe[1]}');
            }
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 05: responsi composti $responsi, frasi con i due '
        'punti annidati ${colpevoli.length}');
    cardinaleMinimo(responsi, 10000,
        cosa: 'responsi composti',
        perche: 'Il difetto nasceva da una combinazione su quattro: con pochi '
            'responsi potrebbe non uscire.');
    expect(colpevoli, isEmpty, reason: colpevoli.take(6).join('\n'));
    // **E LA CUCITURA LO IMPEDISCE ANCHE AL MATERIALE DI DOMANI.**
    expect(LaVoceDelMondoDiSotto.cuci(['Fai questo:', 'Smetti: adesso.']),
        'Fai questo. Smetti: adesso.');
    expect(LaVoceDelMondoDiSotto.cuci(['Fai questo:', 'Smetti adesso.']),
        'Fai questo: smetti adesso.');
    expect(ScenaDelViaggio.aperture.where((a) => a.endsWith(':')), isEmpty,
        reason: 'un apertura della scena finisce ancora coi due punti');
  });

  test('DI.06: le chiusure chiudono, e al massimo due dicono di non decifrare',
      () {
    final sulNonCapire = ScenaDelViaggio.chiusure
        .where((c) => RegExp(
                r'tradur|decifr|senso arriva|non chiederle|basta averla|da sé|'
                r'non capir|lasciala posare',
                caseSensitive: false)
            .hasMatch(c))
        .toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 06: chiusure ${ScenaDelViaggio.chiusure.length}, '
        'sul non decifrare ${sulNonCapire.length}: $sulNonCapire');
    expect(ScenaDelViaggio.chiusure.length, 12);
    expect(sulNonCapire.length,
        // **DUE, dall'ordine DI voce 06.** Il numero stava in lib come
        // costante, e lo leggeva soltanto questa prova: ordine DJ voce 05.
        lessThanOrEqualTo(2),
        reason: 'una risposta che si chiude dicendo di non capirla si '
            'autoassolve: $sulNonCapire');
  });

  test('DI.06: a chi scende senza domanda nessuna chiusura parla della '
      'domanda', () {
    final colpevoli = <String>{};
    for (var i = 0; i < 2000; i++) {
      final s = ScenaSenzaModello.componi(
        domanda: 'solo per incontrarlo $i',
        giorno: DateTime(2026, 9, 12),
        nitidezza: 1,
        discesa: i,
        conDomanda: false,
      );
      for (final t in [s.testo, s.testoSenzaApertura]) {
        if (t.contains('domanda') || t.contains('chiesto')) colpevoli.add(t);
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 06: scene senza domanda che nominano la domanda '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty, reason: colpevoli.take(4).join('\n'));
    expect(ScenaDelViaggio.chiusureSenzaDomanda.length,
        greaterThanOrEqualTo(8),
        reason: 'senza domanda restano troppe poche chiusure, e la misura B '
            'ne soffrirebbe');
  });

  test('DI.05: il richiamo non accorda niente con la figura che torna', () {
    // **Il difetto era un pronome o un participio che si accorda con la
    // figura**: *"La chiave lo avevi gia' trovato"*, *"La piuma era gia'
    // comparso"*. Si cerca il pronome atono prima del verbo e il participio
    // dopo la figura, cioe' le due forme in cui l'accordo e' obbligatorio.
    final colpevoli = IlRichiamoDelleScene.forme
        .where((f) =>
            RegExp(r'\b(lo|la|li|le) (avevi|hai)\b', caseSensitive: false)
                .hasMatch(f) ||
            RegExp(r'\{[Cc]osa\} (era|è) già \w+[oa]\b').hasMatch(f))
        .toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 05: forme del richiamo '
        '${IlRichiamoDelleScene.forme.length}, con un accordo sulla figura '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty, reason: '$colpevoli');
  });
}
