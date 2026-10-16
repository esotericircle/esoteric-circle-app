// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'giudici_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLA STESA CHE INTERPRETA, ordine EQ voce 04.** 27
/// settembre 2026.
///
/// Il fondatore: *"LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA
/// SENSO. SCRIVE QUALCOSA, MA NON DICE NULLA."* e *"Ma una interpretazione la
/// fa veramente o sono testi buttati lì tanto per accontentare?"*.
///
/// **Venti letture sulle stesse estrazioni**, prima e dopo: dieci domande,
/// quattro generiche scelte dall'elenco (fra cui *"Il momento che vivo,
/// lettura generale"*) e sei personali scritte (amore, lavoro, denaro, una
/// scelta, la famiglia, un'amicizia), due estrazioni ciascuna con semi fissi.
/// **Il prima e' la lettura di casa**, `TarotReading.of` senza modello, come
/// la persona la leggeva; **il dopo e' la lettura del modello**, con
/// l'istruzione e la richiesta dell'app (`LaLetturaDellaStesa`), due giri.
///
/// Si misurano, coi giudici a temperatura zero e a maggioranza su tre:
/// - la risposta diretta alla domanda nelle prime due frasi, 20 letture;
/// - ogni carta letta nella sua posizione e rispetto alla domanda, 60 carte;
/// - gli errori di concordanza, dal correttore di bozze;
/// - le letture uguali su cento con la stessa domanda, come nell'ordine DF;
/// - il tempo e i gettoni di ogni chiamata, per l'attesa e il costo.
///
/// ```
/// flutter test tool/collaudo_eq04.dart --dart-define=FASE=prima
/// flutter test tool/collaudo_eq04.dart --dart-define=FASE=dopo --dart-define=GIRO=1
/// flutter test tool/collaudo_eq04.dart --dart-define=FASE=dopo --dart-define=GIRO=2
/// ```
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');
const int giro = int.fromEnvironment('GIRO', defaultValue: 1);

/// **LA TARATURA DEI GIUDICI**, prima di ogni giro vero: casi scritti a mano
/// col verdetto atteso, e i testi di casa stampati col loro verdetto.
/// `flutter test tool/collaudo_eq04.dart --dart-define=TARATURA=true`
const bool taratura = bool.fromEnvironment('TARATURA');

/// **LA SONDA**, prima del giro lungo: dieci letture vere, una per domanda,
/// senza giudici, scritte per essere lette a mano. Il numero la distingue
/// dalle sonde di prima: `--dart-define=SONDA=2`.
const int sonda = int.fromEnvironment('SONDA');

/// Le dieci domande: l'argomento dell'elenco e, per le personali, la frase.
const List<({TarotTopic argomento, String? scritta})> domande = [
  (argomento: TarotTopic.momentoCheVivo, scritta: null),
  (argomento: TarotTopic.amoreQuadro, scritta: null),
  (argomento: TarotTopic.lavoroTrovare, scritta: null),
  (argomento: TarotTopic.cambiamento, scritta: null),
  (argomento: TarotTopic.ritornoAmore, scritta: 'Il mio ex tornerà da me?'),
  (
    argomento: TarotTopic.lavoroTrovare,
    scritta: 'Devo accettare l\'offerta di lavoro che mi hanno fatto a Milano?'
  ),
  (
    argomento: TarotTopic.denaro,
    scritta: 'Riuscirò a mettere da parte i soldi per comprare casa?'
  ),
  (
    argomento: TarotTopic.bivio,
    scritta: 'Resto nella mia città o mi trasferisco dal mio compagno?'
  ),
  (
    argomento: TarotTopic.famiglia,
    scritta: 'Come posso ricucire il rapporto con mio fratello?'
  ),
  (
    argomento: TarotTopic.amicizia,
    scritta: 'La mia migliore amica mi sta nascondendo qualcosa?'
  ),
];

/// I semi delle due estrazioni di ogni domanda: fissi, cosi' prima e dopo
/// leggono le stesse carte.
int semeDi(int domanda, int estrazione) => 2700 + domanda * 10 + estrazione;

/// Una lettura come la persona la legge: la domanda, le tre carte col loro
/// testo, il consiglio.
class LetturaLetta {
  LetturaLetta(this.domanda, this.spread, this.carte, this.testo,
      {this.millesimi = 0,
      this.ingresso = 0,
      this.uscita = 0,
      this.chiamate = 0,
      this.curata = false,
      this.riscritture = 0,
      this.riscritta = false,
      this.scartata});
  final String domanda;

  /// Quante chiamate al modello ha fatto la lettura, secondo tentativo
  /// compreso.
  final int chiamate;

  /// Vero se la lettura mostrata e' passata dall'ultima cura: le frasi col
  /// genere tolte dopo l'ultimo tentativo.
  final bool curata;

  /// Quante riscritture delle frasi col genere ha chiesto la lettura, e se
  /// quella mostrata e' riscritta.
  final int riscritture;
  final bool riscritta;

  /// Perche' la lettura del modello non si e' vista, se non si e' vista: la
  /// persona legge allora quella di casa, ed e' quella che si giudica.
  final String? scartata;
  final TarotSpread spread;

  /// Il testo di ogni carta, nell'ordine passato, presente, futuro.
  final List<String> carte;

  /// Tutto il testo della lettura, dall'inizio: le prime due frasi sono
  /// quelle che si leggono per prime.
  final String testo;
  final int millesimi;
  final int ingresso;
  final int uscita;
  bool diretta = false;
  final List<bool> carteLette = [];
  List<String> concordanza = [];
}

String domandaDa(({TarotTopic argomento, String? scritta}) d) =>
    d.scritta ?? d.argomento.label;

/// **LA LETTURA DI CASA**, come la schermata la mostrava prima: il consiglio
/// di Medora in cima, poi le carte una alla volta col testo del loro verso.
LetturaLetta diCasa(({TarotTopic argomento, String? scritta}) d, int seme) {
  final spread = TarotSpread.draw(seed: seme);
  final r = TarotReading.of(spread, d.argomento, domandaScritta: d.scritta);
  return LetturaLetta(
    domandaDa(d),
    spread,
    [for (final p in r.posizioni) p.testo],
    '${r.consiglio}\n\n'
    '${r.posizioni.map((p) => '${p.drawn.position.label}, ${p.drawn.displayName}: ${p.testo}').join('\n')}',
  );
}

/// **LA LETTURA DEL MODELLO, PER LA STESSA STRADA DELL'APP.** Si chiama
/// `LaLetturaDellaStesa.leggi`, come fa la schermata: la stessa istruzione, la
/// stessa richiesta, la ripulitura, le guardie, il secondo tentativo e la
/// stessa pazienza. Cambia solo il trasporto, `VoceVeraDiGemini.genera`, che
/// conta il tempo e i gettoni. Il testo e' quello che la persona legge,
/// composto da `TarotReading.of`: se le guardie scartano la lettura, e' quello
/// di casa, ed e' quello che si giudica.
Future<LetturaLetta> dalModello(VoceVeraDiGemini voce,
    ({TarotTopic argomento, String? scritta}) d, int seme) async {
  final spread = TarotSpread.draw(seed: seme);
  var millesimi = 0, ingresso = 0, uscita = 0;
  final cronometro = Stopwatch()..start();
  final l = await LaLetturaDellaStesa.leggi(
    spread: spread,
    domanda: domandaDa(d),
    argomento: d.argomento.label,
    forma: CourtesyForm.neutral,
    chiamata: (istruzione, richiesta, campi) async {
      final esito = await voce.genera(
        istruzione: istruzione,
        richiesta: richiesta,
        campi: campi.keys.toList(),
        modello: LaLetturaDellaStesa.modello,
      );
      ingresso += esito.ingresso;
      uscita += esito.uscita;
      // Le riscritture si leggono per intero: sono poche, e dicono se il
      // correttore corregge davvero.
      if (istruzione == LaLetturaDellaStesa.istruzioneDellaRiscrittura) {
        print('EQ.04 RISCRITTURA chiesta:\n$richiesta\nEQ.04 RISCRITTURA '
            'tornata:\n${esito.testo}');
      }
      return esito.testo;
    },
  );
  millesimi = cronometro.elapsedMilliseconds;
  final chiamate = LaLetturaDellaStesa.ultimiTentativi;
  final curata = LaLetturaDellaStesa.ultimaCurata;
  final riscritture = LaLetturaDellaStesa.ultimeRiscritture;
  final riscritta = LaLetturaDellaStesa.ultimaRiscritta;
  final scartata = l == null ? LaLetturaDellaStesa.ultimoScarto : null;
  if (scartata != null) print('EQ.04 scartata: $scartata');
  final r = TarotReading.of(spread, d.argomento,
      domandaScritta: d.scritta, dalModello: l);
  return LetturaLetta(
    domandaDa(d),
    spread,
    [for (final p in r.posizioni) p.testo],
    '${r.consiglio}\n\n'
    '${r.posizioni.map((p) => '${p.drawn.position.label}, ${p.drawn.displayName}: ${p.testo}').join('\n')}',
    millesimi: millesimi,
    ingresso: ingresso,
    uscita: uscita,
    chiamate: chiamate,
    curata: curata,
    riscritture: riscritture,
    riscritta: riscritta,
    scartata: scartata,
  );
}

const int _ragionamento = 512;

Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  var si = 0;
  for (var i = 0; i < 3; i++) {
    if (await voto()) si++;
  }
  return si >= 2;
}

/// Le prime due frasi di [testo], quelle che la persona legge per prime.
String primeDueFrasi(String testo) {
  final frasi = RegExp(r'[^.!?]+[.!?]+')
      .allMatches(testo.replaceAll('\n', ' '))
      .map((m) => m.group(0)!.trim())
      .where((f) => f.isNotEmpty)
      .toList();
  return frasi.take(2).join(' ');
}

/// **IL GIUDICE DELLA RISPOSTA DIRETTA.** Riceve SOLO le prime due frasi,
/// tagliate qui: nella prima stesura riceveva la lettura intera con la
/// consegna di guardare le prime due, e davanti al consiglio di casa, una
/// formula composta dalle carte, diceva si' alla seconda lettura su due.
/// La grandezza e' cambiata, non la soglia: il giudice vede solo cio' che la
/// persona legge per primo, e i casi che non rispondono sono scritti.
Future<bool> giudicaLaRispostaDiretta(
        VoceVeraDiGemini voce, String domanda, String testo) =>
    _aMaggioranza(() => voce.giudica(
          'Una persona ha fatto una stesa di tarocchi con questa domanda: '
          '"$domanda".\n'
          'Qui sotto ci sono le PRIME DUE FRASI della lettura che ha '
          'ricevuto. Rispondono alla sua domanda in modo diretto e concreto?\n'
          '- Se la domanda chiede se una cosa accadra\' o se farla, devono '
          'dire che cosa indicano le carte: si\', no, o a quali condizioni.\n'
          '- Se chiede come fare una cosa, devono dire che cosa fare.\n'
          '- Se la domanda e\' un argomento o una lettura generale, devono '
          'dire in concreto che cosa le carte indicano sulla situazione della '
          'persona in quell\'ambito.\n'
          'Rispondi NO se le due frasi sono una formula che andrebbe bene per '
          'qualunque domanda, se ripetono la domanda senza rispondere, se '
          'parlano per immagini senza dire che cosa significa per lei, o se '
          'descrivono soltanto una carta.\n'
          'Rispondi con una parola sola, SI oppure NO.',
          primeDueFrasi(testo),
          ragionamento: _ragionamento,
        ));

/// **IL GIUDICE DELLA CARTA LETTA.** Riceve anche il significato generale
/// della carta, lo stesso per qualunque posizione e domanda: nella prima
/// stesura non lo riceveva, e davanti al testo di casa, che E' quel
/// significato, diceva si' due volte su tre. Non poteva sapere che quel
/// testo era uguale per ogni posizione e ogni domanda.
Future<bool> giudicaLaCarta(VoceVeraDiGemini voce, String domanda,
        DrawnCard carta, String testo) =>
    _aMaggioranza(() => voce.giudica(
          'Una persona ha fatto una stesa di tarocchi a tre carte, passato, '
          'presente e futuro, con questa domanda: "$domanda".\n'
          'Carta: ${carta.displayName}, nella posizione '
          '${carta.position.label}.\n'
          'Il significato generale di questa carta, lo stesso in qualunque '
          'posizione e per qualunque domanda, e\': "${carta.meaning}"\n'
          'Qui sotto c\'e\' il testo che la lettura dedica a questa carta. '
          'Legge la carta NELLA SUA POSIZIONE (passato: che cosa ha portato '
          'fin qui; presente: che cosa e\' in gioco adesso; futuro: dove va '
          'la situazione) E la collega alla domanda della persona, dicendo '
          'che cosa significa per lei?\n'
          'Rispondi NO se il testo ripete o parafrasa il significato '
          'generale, se non dice niente che dipenda dalla posizione, o se non '
          'si collega alla domanda.\n'
          'Rispondi con una parola sola, SI oppure NO.',
          testo,
          ragionamento: _ragionamento,
        ));

int mediana(List<int> v) {
  if (v.isEmpty) return 0;
  final s = [...v]..sort();
  return s[s.length ~/ 2];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  final cartella = Directory(
      'docs/collaudo/EQ/tarocchi/${fase == 'prima' ? 'prima' : 'dopo_giro_$giro'}');
  final conto = StringBuffer();
  final letture = <LetturaLetta>[];

  setUpAll(() async {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
    // Il gettone di gcloud si paga prima: nell'app non c'e', e la prima
    // lettura misurerebbe lui invece del modello.
    await voce.scaldaIlGettone();
  });

  if (taratura) {
    test('EQ.04 taratura dei giudici su casi noti', () async {
      await _taraIGiudici(voce);
    }, timeout: const Timeout(Duration(minutes: 15)));
    return;
  }

  if (sonda > 0) {
    test('EQ.04 sonda $sonda: dieci letture da leggere a mano', () async {
      final dove = Directory('docs/collaudo/EQ/tarocchi/sonda_$sonda');
      if (!dove.existsSync()) dove.createSync(recursive: true);
      final letture = <LetturaLetta>[];
      for (var i = 0; i < domande.length; i++) {
        final l = await dalModello(voce, domande[i], semeDi(i, 0));
        letture.add(l);
        // I giudici del collaudo, gli stessi e tarati: la sonda dice gia'
        // dove la lettura non risponde o non legge la carta sulla domanda.
        l.diretta = await giudicaLaRispostaDiretta(voce, l.domanda, l.testo);
        for (var c = 0; c < 3; c++) {
          l.carteLette.add(await giudicaLaCarta(
              voce, l.domanda, l.spread.cards[c], l.carte[c]));
        }
        print('EQ.04 sonda $sonda lettura ${i + 1}: diretta ${l.diretta}, '
            'carte ${l.carteLette.where((x) => x).length} su 3; '
            'chiamate ${l.chiamate}, '
            '${l.millesimi} ms, '
            '${l.scartata == null ? 'mostrata' : 'SCARTATA'}; scarti: '
            '${LaLetturaDellaStesa.ultimiScarti.join(' || ')}');
      }
      final b = StringBuffer()
        ..writeln('# Sonda $sonda, dieci letture da leggere a mano')
        ..writeln();
      for (var i = 0; i < letture.length; i++) {
        final l = letture[i];
        b
          ..writeln('## ${i + 1}. ${l.domanda}')
          ..writeln()
          ..writeln('Carte: ${l.spread.cards.map((c) => '${c.position.label} ${c.displayName}').join('; ')}')
          ..writeln()
          ..writeln('> ${l.testo.replaceAll('\n', '\n> ')}')
          ..writeln()
          ..writeln('- lettura del modello: '
              '${l.scartata == null ? 'si' : 'NO, scartata: ${l.scartata}'}; '
              'chiamate ${l.chiamate}, ${l.millesimi} ms')
          ..writeln('- risposta diretta: ${l.diretta ? 'si' : 'NO'}; carte '
              'lette sulla domanda: '
              '${[for (var c = 0; c < 3; c++) '${l.spread.cards[c].position.label} ${l.carteLette[c] ? 'si' : 'NO'}'].join(', ')}')
          ..writeln();
      }
      File('${dove.path}/letture.md').writeAsStringSync(b.toString());
      final mostrate = letture.where((l) => l.scartata == null).length;
      print('EQ.04 sonda $sonda: mostrate $mostrate su ${letture.length}, '
          'con un secondo tentativo '
          '${letture.where((l) => l.chiamate > 1).length}; dirette '
          '${letture.where((l) => l.diretta).length}, carte lette sulla '
          'domanda '
          '${letture.fold<int>(0, (a, l) => a + l.carteLette.where((x) => x).length)} '
          'su ${letture.length * 3}');
    }, timeout: const Timeout(Duration(minutes: 10)));
    return;
  }

  test('EQ.04 $fase: venti letture e i loro giudizi', () async {
    for (var i = 0; i < domande.length; i++) {
      for (var k = 0; k < 2; k++) {
        final seme = semeDi(i, k);
        final l = fase == 'prima'
            ? diCasa(domande[i], seme)
            : await dalModello(voce, domande[i], seme);
        l.diretta = await giudicaLaRispostaDiretta(voce, l.domanda, l.testo);
        for (var c = 0; c < 3; c++) {
          l.carteLette.add(await giudicaLaCarta(
              voce, l.domanda, l.spread.cards[c], l.carte[c]));
        }
        l.concordanza = await erroriDiGrammatica(voce, l.testo);
        letture.add(l);
        print('EQ.04 $fase lettura ${letture.length}: diretta ${l.diretta}, '
            'carte lette ${l.carteLette.where((x) => x).length} su 3, errori '
            '${l.concordanza.length}, chiamate ${l.chiamate}'
            '${l.curata ? ', curata' : ''}'
            '${l.riscritta ? ', riscritta' : ''}'
            '${l.scartata == null ? '' : ', SCARTATA: ${l.scartata}'}');
      }
    }
    final dirette = letture.where((l) => l.diretta).length;
    final carte =
        letture.fold<int>(0, (a, l) => a + l.carteLette.where((x) => x).length);
    final errori = letture.fold<int>(0, (a, l) => a + l.concordanza.length);
    final riga = 'EQ.04 $fase${fase == 'prima' ? '' : ' giro $giro'}: letture '
        'con la risposta diretta nelle prime due frasi $dirette su '
        '${letture.length}; carte lette nella posizione e rispetto alla '
        'domanda $carte su ${letture.length * 3}; errori di concordanza e di '
        'grammatica $errori';
    print(riga);
    conto.writeln(riga);
    if (fase != 'prima') {
      final tempi = [for (final l in letture) l.millesimi];
      final ing = letture.fold<int>(0, (a, l) => a + l.ingresso);
      final usc = letture.fold<int>(0, (a, l) => a + l.uscita);
      final costo = (ing * 0.30 + usc * 2.50) / 1e6 / letture.length;
      final mostrate = letture.where((l) => l.scartata == null).length;
      final seconde = letture.where((l) => l.chiamate > 1).length;
      final curate = letture.where((l) => l.curata).length;
      final riscritte = letture.where((l) => l.riscritta).length;
      final r1 = 'Letture del modello mostrate $mostrate su '
          '${letture.length}, con un secondo tentativo $seconde, curate '
          '$curate, riscritte $riscritte; scartate: '
          '${[for (final l in letture) if (l.scartata != null) l.scartata].join(' | ')}';
      print('EQ.04 $r1');
      conto.writeln(r1);
      final r2 = 'Tempo della lettura dal PC, tentativi compresi, mediana ${mediana(tempi)} ms '
          '(da ${tempi.reduce((a, b) => a < b ? a : b)} a '
          '${tempi.reduce((a, b) => a > b ? a : b)}); gettoni medi in ingresso '
          '${(ing / letture.length).round()}, in uscita '
          '${(usc / letture.length).round()}; costo medio di una stesa '
          '${costo.toStringAsFixed(5)} dollari al listino di Flash (0,30 e 2,50 '
          'dollari per milione)';
      print('EQ.04 $r2');
      conto.writeln(r2);
    }
    _scrivi(cartella, letture);
  }, timeout: const Timeout(Duration(minutes: 40)));

  test('EQ.04 $fase: letture uguali su cento con la stessa domanda', () async {
    const d = (argomento: TarotTopic.denaro, scritta: 'denaro e fortuna');
    final testi = <String>[];
    for (var i = 0; i < 100; i++) {
      final seme = 9000 + i;
      final l = fase == 'prima'
          ? diCasa(d, seme)
          : await dalModello(voce, d, seme);
      testi.add(l.testo);
    }
    final uguali = testi.length - testi.toSet().length;
    final riga = 'EQ.04 $fase${fase == 'prima' ? '' : ' giro $giro'}: letture '
        'uguali su cento con la stessa domanda $uguali';
    print(riga);
    conto.writeln(riga);
  }, timeout: const Timeout(Duration(minutes: 30)));

  tearDownAll(() {
    conto.writeln('Chiamate per le letture ${voce.chiamate}, domande al '
        'giudice ${voce.giudizi}; modello ${LaLetturaDellaStesa.modello}, '
        'europe-west1.');
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}

void _scrivi(Directory cartella, List<LetturaLetta> letture) {
  final b = StringBuffer()..writeln('# Le venti letture, fase $fase')..writeln();
  for (var i = 0; i < letture.length; i++) {
    final l = letture[i];
    b
      ..writeln('## ${i + 1}. ${l.domanda}')
      ..writeln()
      ..writeln('Carte: ${l.spread.cards.map((c) => '${c.position.label} ${c.displayName}').join('; ')}')
      ..writeln()
      ..writeln('> ${l.testo.replaceAll('\n', '\n> ')}')
      ..writeln()
      ..writeln('- risposta diretta nelle prime due frasi: ${l.diretta ? 'si' : 'NO'}')
      ..writeln('- carte lette nella posizione e rispetto alla domanda: '
          '${[for (var c = 0; c < 3; c++) '${l.spread.cards[c].position.label} ${l.carteLette[c] ? 'si' : 'NO'}'].join(', ')}')
      ..writeln('- errori di italiano: ${l.concordanza.isEmpty ? 'nessuno' : l.concordanza.join(' | ')}');
    if (l.millesimi > 0) {
      b.writeln('- lettura del modello: '
          '${l.scartata == null ? 'si' : 'NO, scartata: ${l.scartata}'}; '
          'chiamate ${l.chiamate}, ${l.millesimi} ms'
          '${l.curata ? '; curata, tolte le frasi col genere' : ''}'
          '${l.riscritta ? '; riscritte le frasi col genere' : ''}');
    }
    b.writeln();
  }
  File('${cartella.path}/letture.md').writeAsStringSync(b.toString());
}

DrawnCard _carta(String nome, SpreadPosition posizione,
        {bool capovolta = false}) =>
    DrawnCard(
        card: TarotDeck.cards.firstWhere((c) => c.name == nome),
        position: posizione,
        reversed: capovolta);

/// **I CASI NOTI.** Un giudice che non distingue un testo buono da uno che
/// non risponde non misura niente: qui ogni caso ha il verdetto atteso, e la
/// taratura cade se il giudice ne sbaglia uno.
Future<void> _taraIGiudici(VoceVeraDiGemini voce) async {
  const ex = 'Il mio ex tornerà da me?';
  const milano =
      'Devo accettare l\'offerta di lavoro che mi hanno fatto a Milano?';
  const momento = 'Il momento che vivo, lettura generale';
  final dirette = <(String, String, bool)>[
    (
      ex,
      'Le carte non indicano un ritorno a breve: il Cinque di Coppe nel '
          'presente dice che il legame è ancora una ferita aperta. Un '
          'riavvicinamento resta possibile solo se prima chiudi ciò che è '
          'rimasto in sospeso fra voi.',
      true
    ),
    (
      milano,
      'Sì, le carte spingono ad accettare, a patto che tu chieda prima '
          'condizioni chiare. Il Tre di Denari nel futuro indica un lavoro in '
          'cui il tuo mestiere viene riconosciuto.',
      true
    ),
    (
      momento,
      'Stai attraversando una chiusura che ti chiede di lasciar andare un '
          'vecchio modo di fare. La Morte nel presente dice che il cambiamento '
          'è già cominciato, anche se non l\'hai ancora scelto tu.',
      true
    ),
    (
      ex,
      'Le carte parlano con la voce del tempo: ciò che è stato illumina ciò '
          'che sarà. Ascolta il loro sussurro e lascia che il cuore trovi la '
          'sua strada.',
      false
    ),
    (
      milano,
      'Hai chiesto se accettare l\'offerta di lavoro a Milano. Il Tre di '
          'Denari è una carta di lavoro e di costruzione, legata alla '
          'collaborazione.',
      false
    ),
    (
      momento,
      'Ogni momento porta con sé un insegnamento. Le carte ti invitano ad '
          'ascoltare ciò che senti.',
      false
    ),
  ];
  final cinque = _carta('Cinque di Coppe', SpreadPosition.presente);
  final tre = _carta('Tre di Denari', SpreadPosition.futuro);
  final carte = <(String, DrawnCard, String, bool)>[
    (
      ex,
      cinque,
      'Il Cinque di Coppe nel presente dice che oggi guardi soprattutto a '
          'ciò che hai perso con lui: finché resti su quel rimpianto non vedi '
          'che cosa resta ancora fra voi, né se vale la pena ricostruirlo.',
      true
    ),
    (ex, cinque, cinque.meaning, false),
    (
      ex,
      cinque,
      'Il Cinque di Coppe parla di una perdita e di un rimpianto, ma ricorda '
          'che qualcosa resta ancora in piedi.',
      false
    ),
    (
      milano,
      tre,
      'Il Tre di Denari nel futuro indica che a Milano il tuo lavoro '
          'verrebbe visto e apprezzato da chi lavora con te: l\'offerta può '
          'diventare il posto dove il tuo mestiere cresce, se ci arrivi con '
          'richieste chiare.',
      true
    ),
    (milano, tre, tre.meaning, false),
  ];
  final sbagliati = <String>[];
  for (final (domanda, testo, atteso) in dirette) {
    final v = await giudicaLaRispostaDiretta(voce, domanda, testo);
    print('TARATURA diretta: atteso $atteso, giudice $v: '
        '${primeDueFrasi(testo)}');
    if (v != atteso) sbagliati.add('diretta "$testo"');
  }
  for (final (domanda, carta, testo, atteso) in carte) {
    final v = await giudicaLaCarta(voce, domanda, carta, testo);
    print('TARATURA carta ${carta.displayName}: atteso $atteso, giudice $v: '
        '$testo');
    if (v != atteso) sbagliati.add('carta "$testo"');
  }
  // I testi di casa, col loro verdetto: si stampano per chi legge.
  for (final i in [0, 4, 5, 6]) {
    final casa = diCasa(domande[i], semeDi(i, 0));
    final v = await giudicaLaRispostaDiretta(voce, casa.domanda, casa.testo);
    print('TARATURA casa, diretta $v: ${casa.domanda} | '
        '${primeDueFrasi(casa.testo)}');
    for (var c = 0; c < 3; c++) {
      final vc = await giudicaLaCarta(
          voce, casa.domanda, casa.spread.cards[c], casa.carte[c]);
      print('TARATURA casa, carta ${casa.spread.cards[c].displayName} '
          '${casa.spread.cards[c].position.label}: $vc');
    }
  }
  print('TARATURA casi sbagliati ${sbagliati.length} su '
      '${dirette.length + carte.length}');
  expect(sbagliati, isEmpty, reason: sbagliati.join('\n'));
}
