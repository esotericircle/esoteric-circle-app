import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// Gli accenti a schermo sono accenti, non apostrofi.
///
/// La regola vale da sempre e in una stringa nuova era stata violata: la
/// schermata del genere diceva "LA TUA GUIDA TI DIRA'" con l'apostrofo al
/// posto della A accentata. Ingrandita a piena risoluzione si vede benissimo,
/// perche' un apostrofo sta in alto a destra della lettera e un accento le
/// sta sopra.
///
/// Il test guarda le stringhe, non i commenti: nei commenti l'apostrofo al
/// posto dell'accento e' una convenzione voluta di questo repository, perche'
/// il sorgente resti leggibile ovunque.

/// Le parole italiane che a schermo vogliono l'accento, con la forma
/// sbagliata e quella giusta.
const sbagliate = <String, String>{
  "DIRA'": 'DIRÀ',
  "PERCHE'": 'PERCHÉ',
  "PIU'": 'PIÙ',
  "GIA'": 'GIÀ',
  "PUO'": 'PUÒ',
  "CIOE'": 'CIOÈ',
  "SARA'": 'SARÀ',
  "VERITA'": 'VERITÀ',
  "QUALITA'": 'QUALITÀ',
  "ATTIVITA'": 'ATTIVITÀ',
  "citta'": 'città',
  // **E QUESTE SETTE SONO ARRIVATE DOPO, ordine CO voce 16.** Il
  // fondatore ha letto "Se da' fastidio" dentro il Rito dell'Alba e ha
  // chiesto l'accento vero. **Questa guardia non era cieca: il suo
  // elenco non conteneva la parola.** E' la stessa specie del difetto
  // degli accenti usati come inchiostro, trovato nello stesso ordine:
  // non una guardia che guarda male, un insieme che non contiene il
  // caso. Un elenco scritto a mano dimentica sempre una parola, e
  // l'unico rimedio onesto e' allungarlo appena una manca.
  "DA'": 'DÀ',
  "PERO'": 'PERÒ',
  "COSI'": 'COSÌ',
  "NE'": 'NÉ',
  "SE'": 'SÉ',
  "LI'": 'LÌ',
};

/// Un punto dove la parola finisce davvero cosi', dichiarato per nome.
class Esenzione {
  const Esenzione(this.percorso, this.riga, this.ragione);

  /// Il file, da `lib/`.
  final String percorso;

  /// **LA RIGA PER INTERO, senza gli spazi in testa e in coda.** Ordine DS
  /// voce 04: prima qui c'era il NUMERO della riga.
  final String riga;

  final String ragione;

  @override
  String toString() => '$percorso: $riga';
}

/// **I PUNTI DOVE LA PAROLA FINISCE DAVVERO COSI', dichiarati per nome.**
/// Ordine CO voce 16, 3 settembre 2026.
///
/// Questa prova spezza la riga sugli apici e guarda come FINISCE ogni pezzo.
/// E' il modo giusto e ha un limite di forma: una stringa che termina
/// legittimamente con la preposizione "da" e' indistinguibile da una che
/// finisce col verbo scritto male. Non e' una debolezza da nascondere, e' il
/// prezzo di una misura semplice che ha appena trovato quattro difetti veri;
/// le righe che sbaglia si scrivono qui col perche'.
///
/// **LA CHIAVE E' IL CONTENUTO DELLA RIGA, NON IL SUO NUMERO. Ordine DS voce
/// 04, 17 settembre 2026.** La tavola era indicizzata per numero di riga e si
/// e' spostata tre volte: con l'ordine DL voce 09 (a 177), con l'ordine DQ
/// voce 08 (a 276 e 417) e con l'ordine DM voce 03, per un import che ha
/// portato la riga 473 alla 474. Ogni volta si pagava aggiornando il numero.
///
/// **E la tavola non e' diventata piu' larga, e' diventata piu' stretta.** Il
/// numero esentava una riga; il contenuto esenta la riga con quel testo, e
/// due prove qui sotto pretendono che **ogni esenzione trovi esattamente una
/// riga nel suo file**: se la riga cambia l'esenzione muore e la prova cade,
/// se il testo compare due volte l'esenzione e' ambigua e la prova cade. Prima
/// un'esenzione rimasta su un numero sbagliato esentava in silenzio una riga
/// qualunque. Undici esenzioni prima, undici dopo.
const esenzioni = <Esenzione>[
  // Ordine DI voce 02, 12 settembre 2026: un indizio della tabella che
  // capisce le domande libere, "non so se trasferirmi", dove "se" e' la
  // congiunzione e la stringa finisce legittimamente cosi'. Non si mostra.
  Esenzione(
      'lib/core/viaggio/il_tema_della_domanda_libera.dart',
      "('non so se', 3),",
      'e un indizio della tabella delle domande libere, "non so se" con la '
          'congiunzione, e non una parola mostrata'),
  Esenzione(
      'lib/core/lang/euphonic.dart',
      "'da': {",
      'e la tavola delle preposizioni articolate, dove "da" e una CHIAVE '
          'di mappa e non una parola mostrata: da, dal, dallo, dalla'),
  Esenzione(
      'lib/features/santuario/sky_overview_screen.dart',
      "_rigaValore(palette, 'Coordinate da', _origine.etichetta),",
      'e l etichetta "Coordinate da", che finisce con la preposizione '
          'perche il valore le viene scritto accanto'),
  // **LE PAROLE VUOTE DELLA DOMANDA SONO CHIAVI, NON TESTO. Ordine CQ voce
  // 6.10.**
  //
  // Quell elenco serve a togliere le parole comuni dalla domanda che la
  // persona scrive, e **la persona scrive senza accenti**: chi digita
  // "perche" o "piu" sulla tastiera del telefono deve essere capito lo
  // stesso. Per questo l elenco porta tutte e due le forme, con e senza,
  // e quelle senza non escono mai a video.
  // **ORDINE DL VOCI 07 E 08**: le parole di cornice dell'oggetto della
  // domanda e le parole vuote della risposta del modello sono chiavi di
  // confronto, come quelle della domanda dei tarocchi qui sotto.
  Esenzione(
      'lib/core/viaggio/la_domanda_capita.dart',
      "'da',",
      'e la tavola delle parole di cornice dell oggetto, dove "da" e la '
          'preposizione che l oggetto puo avere senza che la domanda la '
          'contenga, una CHIAVE di confronto'),
  Esenzione(
      'lib/core/viaggio/le_guardie_del_responso.dart',
      "'perche',",
      'e la tavola delle parole vuote della domanda, dove perche senza '
          'accento e la forma che la persona digita, una CHIAVE'),
  // **ORDINE DQ VOCE 08**: la tavola delle parole che stanno in testa a
  // una domanda senza essere un nome, "Perche" e "Se" digitati senza
  // accento sulla tastiera del telefono. Chiavi di confronto.
  Esenzione(
      'lib/core/viaggio/le_guardie_del_responso.dart',
      "'perché', 'perche', 'quale', 'quali',",
      'e la tavola dei non nomi in testa alla domanda, dove perche senza '
          'accento e la forma che la persona digita, una CHIAVE'),
  Esenzione(
      'lib/core/viaggio/le_guardie_del_responso.dart',
      "'e', 'ma', 'però', 'poi', 'quindi', 'allora', 'anche', 'se', 'non', 'né',",
      'stessa tavola: se e la congiunzione in testa alla domanda, una '
          'chiave di confronto'),
  Esenzione(
      'lib/core/tarot/domanda_della_persona.dart',
      "'che', 'chi', 'come', 'cosa', 'quando', 'dove', 'perche', 'perché',",
      'e la tavola delle parole vuote, dove perche e una CHIAVE di '
          'confronto e non una parola mostrata'),
  Esenzione(
      'lib/core/tarot/domanda_della_persona.dart',
      "'miei', 'mie', 'suo', 'sua', 'loro', 'non', 'piu', 'più', 'gli', 'lei',",
      'stessa tavola: piu e una chiave di confronto'),
  Esenzione(
      'lib/core/tarot/domanda_della_persona.dart',
      "'lui', 'noi', 'voi', 'sara', 'sarà', 'ho', 'mi', 'si', 'ti', 'ci',",
      'stessa tavola: sara e una chiave di confronto'),
  Esenzione(
      'lib/core/tarot/domanda_della_persona.dart',
      "'impresa', 'libreria', 'negozio', 'attivita', 'attività'],",
      'stessa tavola: attivita e una chiave di confronto'),
];

/// Le stringhe di [righe] che usano l'apostrofo al posto dell'accento.
///
/// [usate] conta, per ogni esenzione, quante righe ha esentato: e' cosi' che
/// una prova sa se un'esenzione e' morta o ambigua.
List<String> colpevoliIn(String percorso, List<String> righe,
    {Map<Esenzione, int>? usate}) {
  final colpevoli = <String>[];
  final mie = esenzioni.where((e) => e.percorso == percorso).toList();
  var n = 0;
  for (final riga in righe) {
    n++;
    final pulita = riga.trimLeft();
    // Via i commenti: li' l'apostrofo e' una convenzione di questo
    // repository, non un errore.
    if (pulita.startsWith('//')) continue;
    final esente = mie.where((e) => e.riga == riga.trim()).toList();
    // Le stringhe della riga, prese col piu' semplice dei modi: fra due
    // apici, senza inseguire le sequenze di fuga. Basta allo scopo.
    final pezzi = riga.split("'");
    var colpita = false;
    for (var k = 1; k < pezzi.length; k += 2) {
      // **VIA LA BARRA DI PROTEZIONE, e questa riga nasce da un buco
      // vero.** Ordine CF voce 14, coda del 31 agosto 2026. Nel codice
      // l\'apice dentro una stringa si scrive protetto, e allora lo
      // spezzone che arriva qui finisce con la barra: "Perche" seguito
      // dalla barra non e\' uguale a "Perche", e la parola sbagliata
      // passava. **E\' successo davvero**: `Text('Perche\\' proprio lui')`
      // e\' arrivato fino all\'anteprima con questa prova verde, e a
      // trovarlo e\' stato l\'occhio sull\'immagine.
      final testo = pezzi[k].endsWith(r'\')
          ? pezzi[k].substring(0, pezzi[k].length - 1)
          : pezzi[k];
      // **E SENZA BADARE ALLE MAIUSCOLE, seconda meta' dello stesso
      // buco.** L'elenco porta "PERCHE'" e "perche'", e "Perche'" con la
      // sola iniziale grande non era nessuno dei due: e' proprio la forma
      // con cui la parola sbagliata e' passata. Un elenco che deve
      // prevedere ogni maiuscola e' un elenco che dimentica sempre una
      // forma.
      final testoBasso = testo.toLowerCase();
      for (final e in sbagliate.entries) {
        final chiaveSenzaApice =
            e.key.substring(0, e.key.length - 1).toLowerCase();
        // La stringa e' spezzata sull'apice, quindi la forma sbagliata
        // compare come parola che FINISCE il pezzo: "TI DIRA" seguito
        // dall'apice che ha spezzato.
        if (testoBasso.endsWith(chiaveSenzaApice) &&
            (testoBasso.length == chiaveSenzaApice.length ||
                ' .,;:!?('.contains(testoBasso[
                    testoBasso.length - chiaveSenzaApice.length - 1]))) {
          if (esente.isNotEmpty) {
            colpita = true;
            continue;
          }
          colpevoli.add('$percorso:$n  "$testo" va scritto ${e.value}');
        }
      }
    }
    if (colpita && usate != null) {
      for (final e in esente) {
        usate[e] = (usate[e] ?? 0) + 1;
      }
    }
  }
  return colpevoli;
}

String _daLib(File f) {
  final percorso = f.path.replaceAll(r'\', '/');
  return percorso.substring(percorso.indexOf('lib/'));
}

void main() {
  test('Nessuna stringa mostrata usa l\'apostrofo al posto dell\'accento', () {
    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()) {
      colpevoli.addAll(colpevoliIn(_daLib(f), f.readAsLinesSync()));
    }
    expect(colpevoli, isEmpty,
        reason: 'accenti resi con l\'apostrofo a schermo:\n'
            '${colpevoli.take(12).join('\n')}');
  });

  test('OGNI ESENZIONE TROVA LA SUA RIGA, UNA SOLA, e la usa', () {
    // **Ordine DS voce 04.** Un'esenzione per contenuto che non trova piu' la
    // sua riga e' morta: la riga e' cambiata, e se la parola sbagliata e'
    // tornata altrove non la copre nessuno. Una che trova due righe e'
    // ambigua: esenterebbe anche la seconda senza che nessuno l'abbia
    // dichiarata. **Tutte e due fanno cadere questa prova.**
    final usate = <Esenzione, int>{};
    final quanteVolte = <Esenzione, int>{};
    for (final e in esenzioni) {
      final righe = File(e.percorso).readAsLinesSync();
      quanteVolte[e] = righe.where((r) => r.trim() == e.riga).length;
      colpevoliIn(e.percorso, righe, usate: usate);
    }
    final morte = [
      for (final e in esenzioni)
        if ((quanteVolte[e] ?? 0) == 0) '$e'
    ];
    final ambigue = [
      for (final e in esenzioni)
        if ((quanteVolte[e] ?? 0) > 1) '$e (${quanteVolte[e]} righe)'
    ];
    final inutili = [
      for (final e in esenzioni)
        if ((quanteVolte[e] ?? 0) == 1 && (usate[e] ?? 0) == 0) '$e'
    ];
    // ignore: avoid_print
    print('ORDINE DS VOCE 04: esenzioni ${esenzioni.length}, parole '
        'sorvegliate ${sbagliate.length}, morte ${morte.length}, ambigue '
        '${ambigue.length}, che non esentano niente ${inutili.length}');
    expect(morte, isEmpty,
        reason: 'queste esenzioni non trovano piu la loro riga:\n'
            '${morte.join('\n')}');
    expect(ambigue, isEmpty,
        reason: 'queste esenzioni trovano piu di una riga:\n'
            '${ambigue.join('\n')}');
    expect(inutili, isEmpty,
        reason: 'queste esenzioni trovano la riga e non esentano niente: la '
            'parola sbagliata se n e andata, e l esenzione va tolta:\n'
            '${inutili.join('\n')}');
  });

  test('LE ESENZIONI RESTANO VERE SE LE RIGHE SI SPOSTANO', () {
    // **Ordine DS voce 04, la prova che l'ordine chiede.** Si prende ogni
    // file esentato, gli si infilano in testa sette righe, come fa un import
    // nuovo, e si guarda di nuovo: le esenzioni devono valere come prima, e
    // una parola sbagliata innestata nello stesso file deve cadere lo stesso.
    final perFile = <String>{for (final e in esenzioni) e.percorso};
    var spostati = 0;
    for (final percorso in perFile) {
      final righe = File(percorso).readAsLinesSync();
      final prima = <Esenzione, int>{};
      final dopo = <Esenzione, int>{};
      expect(colpevoliIn(percorso, righe, usate: prima), isEmpty);
      final spostate = [
        for (var i = 0; i < 7; i++) "import 'riga_$i.dart';",
        ...righe,
      ];
      expect(colpevoliIn(percorso, spostate, usate: dopo), isEmpty,
          reason: 'spostate le righe di $percorso, un\'esenzione non vale piu');
      expect(dopo, prima,
          reason: 'spostate le righe di $percorso, le esenzioni esentano '
              'altro da prima');
      // E la tavola non esenta il file intero: una parola sbagliata nuova,
      // nello stesso file spostato, cade.
      final innestate = [
        ...spostate,
        "  final avviso = Text('Te lo dira'');",
      ];
      expect(colpevoliIn(percorso, innestate), hasLength(1),
          reason: 'in $percorso una stringa sbagliata nuova passa: la tavola '
              'esenta piu di quello che dichiara');
      spostati++;
    }
    // ignore: avoid_print
    print('ORDINE DS VOCE 04: file esentati spostati di sette righe $spostati');
    expect(spostati, greaterThanOrEqualTo(5));
  });
}
