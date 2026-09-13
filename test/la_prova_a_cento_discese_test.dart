// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;
import 'motore_della_ripetizione.dart';

/// **LA PROVA A CENTO DISCESE.** Ordine DI voce 16, 13 settembre 2026.
///
/// *"Si applicano le quattro misure gia' definite nell'ordine DF, su cento
/// discese consecutive con la stessa domanda e lo stesso profilo, ripetute per
/// ciascuno dei sei temi e per cinque domande libere diverse [...] Si aggiunge
/// una quinta misura [...] E, pertinenza: su cento discese per ciascuno dei sei
/// temi, il responso contiene un riferimento riconoscibile al tema in almeno 95
/// casi su 100. Con la domanda libera, il riferimento e' al tema classificato.
/// La prova gira senza rete e con rete, e il rapporto riporta le due colonne
/// separate, perche' senza rete lavorano le vie di riserva."*
///
/// **LA STRADA E' QUELLA DELL'APP, non una sua copia.** Un Diario vero, a cui
/// cento giorni consecutivi aggiungono una discesa ciascuno: la memoria per il
/// modello e le ultime cinque scene crescono come crescono nell'app. Il tema
/// della domanda libera lo decide `LaDomandaCapita.tema`, la scena
/// `LaScenaDalModello.chiedi` e, quando non arriva, `ScenaSenzaModello.componi`,
/// con gli stessi argomenti che passa la risalita della schermata; il responso
/// e' il titolo, i tre paragrafi e il richiamo, cioe' cio' che la schermata
/// mette a schermo.
///
/// **SENZA RETE** le due chiamate al modello falliscono come fallisce una
/// chiamata senza rete, e lavorano le vie di riserva: la tabella delle parole e
/// la composizione deterministica. Gira sempre, ed e' una guardia.
///
/// **CON RETE** le due chiamate sono quelle vere, a Vertex AI, con lo stesso
/// modello, la stessa regione, la stessa istruzione e la stessa configurazione
/// della chiamata dell'app: cambia soltanto il trasporto, REST invece della
/// libreria di Firebase, che in una prova non c'e'. Gira solo quando riceve un
/// token nella variabile d'ambiente `VERTEX_TOKEN`:
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test test/la_prova_a_cento_discese_test.dart
///
/// Il token non si scrive in nessun file.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  _Token.valore = token;

  test('SENZA RETE: le cinque misure su cento discese, per i sei temi e per '
      'cinque domande libere', () async {
    final esiti = <_Esito>[];
    for (final caso in _casi) {
      esiti.add(await _centoDiscese(caso, conRete: false));
    }
    _stampa('SENZA RETE', esiti);
    // **LA GUARDIA**: sui sei temi scritti le cinque misure dell'ordine
    // devono passare tutte, senza rete, sempre. Sulle domande libere la
    // pertinenza dipende da cosa capisce la tabella, e la tabella senza rete
    // capisce una domanda su tre per dichiarazione della voce DI.02: le misure
    // si riportano, e cadono soltanto A, B, C e D.
    final cadute = [
      for (final e in esiti)
        for (final m in e.cedute(conPertinenza: e.caso.temaScritto != null))
          '${e.caso.nome}: $m',
    ];
    expect(cadute, isEmpty,
        reason: 'SENZA RETE hanno ceduto:\n${cadute.join('\n')}');
  }, timeout: const Timeout(Duration(minutes: 10)));

  /// **IL RICHIAMO NELLA SCHERMATA VERA**, alla prima discesa della storia di
  /// una persona: il Diario non ha niente, quindi non c'e' niente da
  /// richiamare. Prima dell'ordine DI voce 16 il richiamo si calcolava dopo
  /// aver segnato la discesa di oggi, e compariva sempre.
  testWidgets('ALLA PRIMA DISCESA NON C E NESSUN RICHIAMO, nella schermata vera',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Il Diario finto dice una discesa gia' fatta, perche' la lente e il
    // salto del filmato arrivano dalla seconda: ma di scene non ne ha
    // nessuna, ed e' questo che il richiamo guarda.
    final diario = DiarioDelloSciamanoDiProva(1);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 13, 12),
            diario: diario,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_risali')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    // **IL CARDINALE**: la risalita c'e', col suo titolo.
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget);
    expect(diario.viaggi, hasLength(1));
    expect(find.byKey(const Key('viaggio_richiamo')), findsNothing,
        reason: 'alla prima scena della sua storia la persona legge che una '
            'cosa era gia comparsa: il richiamo guarda anche la scena di '
            'oggi');
  });

  test('CON RETE: le cinque misure su cento discese, col modello vero',
      () async {
    HttpOverrides.global = null;
    // **UNA DISCESA ALLA VOLTA**, come per una persona: la prima stesura
    // faceva girare gli undici casi insieme, undici chiamate contemporanee, e
    // la latenza sotto quel carico faceva scadere i due secondi di pazienza.
    final esiti = <_Esito>[];
    for (final caso in _casi) {
      esiti.add(await _centoDiscese(caso, conRete: true, token: token));
    }
    _stampa('CON RETE', esiti);
    final chiamate = esiti.fold<int>(0, (s, e) => s + e.chiamate);
    final ingresso = esiti.fold<int>(0, (s, e) => s + e.tokenIngresso);
    final uscita = esiti.fold<int>(0, (s, e) => s + e.tokenUscita);
    print('CHIAMATE AL MODELLO: $chiamate, token in ingresso $ingresso, in '
        'uscita $uscita');
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 40)));
}

/// Un caso della prova: una domanda, e il tema quando e' una delle sei.
class _Caso {
  const _Caso(this.nome, this.domanda, this.temaScritto);
  final String nome;
  final String domanda;
  final TemaDellaDomanda? temaScritto;
}

/// **I SEI TEMI**, con la loro domanda per esteso, e **CINQUE DOMANDE
/// LIBERE** scritte per questa prova, diverse per forma e per tema: una che
/// parla di una persona e chiede quando, che e' l'esempio della voce DI.02, e
/// quattro su lavoro, famiglia, blocco e fine.
final List<_Caso> _casi = [
  for (final d in LaDomandaDelViaggio.gliaScritte)
    _Caso('tema ${d.chiave.name}', d.testo, d.chiave),
  const _Caso('libera 1', 'Mia sorella diventerà presto mamma?', null),
  const _Caso('libera 2',
      'Devo lasciare il mio lavoro per aprire qualcosa di mio?', null),
  const _Caso('libera 3', 'Perché con mio padre finisce sempre in lite?', null),
  const _Caso('libera 4',
      'Da mesi non riesco a finire niente di quello che comincio.', null),
  const _Caso('libera 5', 'Ho chiuso con Luca dopo sei anni, e adesso?', null),
];

/// **IL PROFILO**, lo stesso della prova col modello vero della voce DI.03:
/// il Lupo, Sole in Cancro, Luna in Scorpione, Ascendente Pesci, numero 7.
const NatalContext _natale = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Scorpione',
  ascendant: 'Pesci',
  lifeNumber: 7,
);

class _Esito {
  _Esito(this.caso, this.misura, this.pertinenti, this.temi, this.dalModello,
      this.chiamate, this.tokenIngresso, this.tokenUscita, this.esempio);
  final _Caso caso;
  final EsitoDellaRipetizione misura;

  /// In quante discese su cento il responso contiene un riferimento
  /// riconoscibile al tema.
  final int pertinenti;

  /// Il tema a ogni discesa, per le domande libere: da dove viene.
  final Map<String, int> temi;

  /// In quante discese la scena l'ha scelta il modello.
  final int dalModello;
  final int chiamate;
  final int tokenIngresso;
  final int tokenUscita;
  final String esempio;

  /// **LA RIPETIZIONE BLOCCO PER BLOCCO**: per il titolo, i tre paragrafi e
  /// il richiamo, quante volte torna il blocco piu' ripetuto. Dice quale
  /// pezzo del responso fa cadere la misura D.
  late final Map<String, int> perBlocco = () {
    const nomi = ['titolo', 'risposta', 'gesto', 'da dove', 'richiamo'];
    final conti = <String, Map<String, int>>{};
    for (final t in testi) {
      final blocchi = t.split('\n\n');
      for (var k = 0; k < blocchi.length && k < nomi.length; k++) {
        final c = conti.putIfAbsent(nomi[k], () => {});
        c[blocchi[k]] = (c[blocchi[k]] ?? 0) + 1;
      }
    }
    return {
      for (final e in conti.entries)
        e.key: e.value.values.fold<int>(0, (a, b) => a > b ? a : b),
    };
  }();
  List<String> testi = const [];
  int conRichiamo = 0;

  /// **LA DISTANZA MINIMA FRA DUE RITORNI** della stessa frase del gesto e
  /// della stessa frase della risposta, in discese. Ordine DI voce 16: le
  /// cinque misure non vedono la stessa azione suggerita a tre giorni di
  /// distanza, e chi legge si'.
  int distanzaDelGesto = 1000;
  int distanzaDellaRisposta = 1000;

  /// **PERCHE' IL MODELLO NON HA DECISO**, per tipo: tempo scaduto, scena
  /// scartata dalla lettura, tema fuori dai sei, errore di rete.
  Map<String, int> guasti = const {};

  /// **LE DISCESE IN CUI IL RICHIAMO MENTE**: c'e' e la cosa non era nelle
  /// cinque di prima, o manca e c'era. Devono essere zero.
  List<String> richiamiFalsi = const [];

  bool get passaC =>
      misura.somiglianzaMassima < MotoreDellaRipetizione.sogliaSomiglianza;
  bool get passaE => pertinenti >= 95;

  List<String> cedute({required bool conPertinenza}) => [
        if (!misura.passaA) 'A ${misura.testiDistinti}/100',
        if (!misura.passaB)
          'B ${misura.scheletriDistinti} scheletri, il piu ripetuto '
              '${misura.quanteVolteLoScheletro} volte',
        if (!passaC)
          'C ${(misura.somiglianzaMassima * 100).toStringAsFixed(1)} per '
              'cento sulla coppia peggiore di tutte le 4950',
        if (!misura.passaD) 'D ${misura.quanteVolteIlParagrafo} volte',
        if (conPertinenza && !passaE) 'E $pertinenti/100',
        if (distanzaDelGesto < LaVoceDelMondoDiSotto.cosaPuoiFare.length)
          'la stessa azione torna dopo $distanzaDelGesto discese',
        // La risposta al massimo un posto prima, al passaggio fra due tratti
        // del ciclo: vedi `LaVoceDelMondoDiSotto`.
        if (caso.temaScritto != null &&
            distanzaDellaRisposta <
                LaVoceDelMondoDiSotto.rispostePerTema[caso.temaScritto!.name]!
                        .length -
                    1)
          'la stessa risposta torna dopo $distanzaDellaRisposta discese',
        if (richiamiFalsi.isNotEmpty)
          'il richiamo mente in ${richiamiFalsi.length} discese, per esempio '
              '${richiamiFalsi.first}',
      ];
}

/// **CENTO DISCESE CONSECUTIVE**, un giorno ciascuna, con la stessa domanda.
Future<_Esito> _centoDiscese(_Caso caso,
    {required bool conRete, String token = ''}) async {
  final inizio = DateTime(2026, 9, 14, 12);
  var oggi = inizio;
  // **SENZA `carica`**: il Diario parte vuoto e resta di questo caso, anche
  // se i casi girano insieme sulla stessa memoria finta.
  final diario = DiarioDeiViaggi(orologio: () => oggi);
  final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
  final testi = <String>[];
  final nomi = <List<String>>[];
  final simboli = <Set<String>>[];
  final temi = <String, int>{};
  var pertinenti = 0;
  var dalModello = 0;
  final conto = _Conto();
  final guasti = <String, int>{};
  void guasto(Object e) {
    final tipo = e is TimeoutException
        ? 'tempo scaduto'
        : e is ScenaFuoriDalVocabolario
            ? 'scena scartata'
            : e is RispostaFuoriDaiSei
                ? 'tema fuori dai sei'
                : e.runtimeType.toString();
    guasti[tipo] = (guasti[tipo] ?? 0) + 1;
  }

  final ChiamataDelModello chiamataDelTema = conRete
      ? (i, d) => _vertex(token, LaDomandaCapita.modello, i, d, conto,
              temperatura: 0,
              tetto: 64,
              mime: 'text/x.enum',
              schema: {
                'type': 'STRING',
                'enum': [for (final t in TemaDellaDomanda.values) t.name],
              })
      : (i, d) async => throw const SocketException('senza rete');
  // **LO SCHEMA E' QUELLO DELLA CHIAMATA VERA**, dai pezzi ammessi oggi.
  final ChiamataDellaScena chiamataDellaScena = conRete
      ? (i, r, a) => _vertex(token, LaScenaDalModello.modello, i, r, conto,
              temperatura: 0.8,
              tetto: 256,
              mime: 'application/json',
              schema: {
                'type': 'OBJECT',
                'properties': {
                  'luogo': {'type': 'STRING', 'enum': a.luoghi},
                  'cosa': {'type': 'STRING', 'enum': a.cose},
                  'gesto': {'type': 'STRING', 'enum': a.gesti},
                  'momento': {'type': 'STRING', 'enum': a.momenti},
                },
              })
      : (i, r, a) async => throw const SocketException('senza rete');

  String esempio = '';
  var conRichiamo = 0;
  final richiamiFalsi = <String>[];
  final composti = <String>[];
  for (var i = 0; i < MotoreDellaRipetizione.quante; i++) {
    oggi = inizio.add(Duration(days: i));
    // 1. il tema: quello scritto, o quello che si capisce.
    var tema = caso.temaScritto;
    if (tema == null) {
      final (capito, fonte) = await LaDomandaCapita.tema(caso.domanda,
          chiamata: chiamataDelTema,
          prendiUnaChiamata: () async => true,
          seGuasto: conRete ? guasto : null);
      tema = capito;
      final chiave = '${capito?.name ?? 'nessuno'} (${fonte.name})';
      temi[chiave] = (temi[chiave] ?? 0) + 1;
    }
    // 2. la scena, come la sceglie la risalita.
    final quante = diario.quanteDiscese;
    final nitidezza =
        NitidezzaDellaScena.dopoGiorni(diario.giorniDiDistanza ?? 0);
    final domanda = LaDomandaDelViaggio.oppureIlMomento(caso.domanda);
    final scelti = await LaScenaDalModello.chiedi(
      CioCheSiSa(
        domanda: caso.domanda,
        tema: tema?.inLettere,
        animale: animale,
        natale: _natale,
        memoria: diario.riassuntoPerIMaestri,
        ultimeScene: [for (final v in diario.viaggi) v.pezzi],
      ),
      chiamata: chiamataDellaScena,
      prendiUnaChiamata: () async => true,
      seGuasto: conRete ? guasto : null,
    );
    // **LE DISCESE DI PRIMA, prese prima di segnare questa**, come fa la
    // schermata dall'ordine DI voce 16.
    final precedenti = [for (final v in diario.viaggi) v.pezzi];
    final responso = IlResponsoDelViaggio.componi(
      dalModello: scelti,
      domanda: domanda,
      giorno: oggi,
      nitidezza: nitidezza,
      discesa: quante,
      giaOggi: diario.quanteOggi,
      animale: animale,
      tema: tema,
      precedenti: precedenti,
    );
    if (responso.dalModello) dalModello++;
    final scena = responso.scena;
    // **IL RICHIAMO DICE IL VERO**: quando c'e', la cosa di oggi era in una
    // delle cinque discese di prima. Quando c'era e manca non e' una bugia:
    // il richiamo e' raro per scelta, e fra due richiami ci sono tre
    // discese di pausa.
    final visti = {
      for (final p
          in precedenti.take(IlRichiamoDelleScene.quanteSceneIndietro))
        ...p,
    };
    if (responso.richiamo != null && !visti.contains(scena.cosa.id)) {
      richiamiFalsi.add('discesa ${i + 1}: ${responso.richiamo}');
    }
    if (responso.richiamo != null) conRichiamo++;
    await diario.segna(UnViaggio(
      quando: oggi,
      domanda: domanda,
      temaDellaDomanda: tema?.name ?? '',
      pezzi: scena.idDeiPezzi,
      animaleSeguito: animale.name,
      nitidezza: nitidezza,
    ));
    final testo = responso.blocchi.join('\n\n');
    if (i == 6) esempio = testo;
    testi.add(testo);
    // **LA MISURA D GUARDA I PARAGRAFI COMPOSTI**, senza il titolo: e' la
    // regola del motore dell'ordine DF, che per la Stesa conta il paragrafo
    // piu' ripetuto sul Consiglio e non sul titolo. Il titolo si conta a
    // parte e si riporta col suo numero, in `perBlocco`.
    composti.add(responso.blocchi.skip(1).join('\n\n'));
    simboli.add(scena.idDeiPezzi.toSet());
    nomi.add([
      scena.luogo.nome,
      scena.cosa.nome,
      scena.gesto.nome,
      scena.momento.nome,
      animale.name,
    ]);
    if (tema != null && _riconosceIlTema(testo, tema)) pertinenti++;
  }
  final misura = MotoreDellaRipetizione.misura(
    funzione: caso.nome,
    testi: testi,
    nomiPerTesto: nomi,
    testiComposti: composti,
    simboliPerTesto: simboli,
  );
  return _Esito(caso, misura, pertinenti, temi, dalModello, conto.chiamate,
      conto.ingresso, conto.uscita, esempio)
    ..testi = testi
    ..conRichiamo = conRichiamo
    ..distanzaDelGesto = _distanzaMinima(testi, 2, LaVoceDelMondoDiSotto.cosaPuoiFare)
    ..distanzaDellaRisposta = _distanzaMinima(
        testi,
        1,
        LaVoceDelMondoDiSotto.rispostePerTema[caso.temaScritto?.name] ??
            LaVoceDelMondoDiSotto.risposteSenzaDomanda)
    ..richiamiFalsi = richiamiFalsi
    ..guasti = guasti;
}

/// **LA DISTANZA MINIMA** fra due discese che nel blocco [blocco] contengono
/// la stessa frase di [frasi]. La prima lettera non si confronta, perche' la
/// cucitura la mette minuscola dopo i due punti.
int _distanzaMinima(List<String> testi, int blocco, List<String> frasi) {
  final ultima = <int, int>{};
  var minima = 1000;
  for (var i = 0; i < testi.length; i++) {
    final b = testi[i].split('\n\n');
    if (b.length <= blocco) continue;
    final testo = b[blocco].toLowerCase();
    for (var k = 0; k < frasi.length; k++) {
      final f = frasi[k].toLowerCase();
      if (!testo.contains(f.substring(1))) continue;
      final prima = ultima[k];
      if (prima != null && i - prima < minima) minima = i - prima;
      ultima[k] = i;
    }
  }
  return minima;
}

/// **UN RIFERIMENTO RICONOSCIBILE AL TEMA**, misura E.
///
/// Il responso lo contiene quando nomina il tema con le parole dell'elenco,
/// *"una scelta da fare"*, o con le sue due parole, *"la scelta"*, oppure
/// quando contiene una delle frasi scritte soltanto per quel tema: i suoi
/// titoli e le sue risposte. Sono le tre forme in cui una persona riconosce
/// che le si sta rispondendo su cio' che ha chiesto; una figura della scena
/// che per caso si chiama come il tema, il *bivio* per una scelta, non conta.
bool _riconosceIlTema(String testo, TemaDellaDomanda tema) {
  final t = testo.toLowerCase();
  final nome = tema.inLettere.toLowerCase();
  final breve = LaVoceDelMondoDiSotto.temaInDueParole[tema.name]!.toLowerCase();
  if (t.contains(nome) || t.contains(breve)) return true;
  final proprie = [
    ...?LaVoceDelMondoDiSotto.titoliPerTema[tema.name],
    ...?LaVoceDelMondoDiSotto.rispostePerTema[tema.name],
  ];
  return proprie.any((f) => t.contains(f.toLowerCase()));
}

/// **IL TOKEN, CHE SI RINNOVA.** `gcloud` restituisce un token in cache, che
/// puo' scadere a meta' di una prova lunga: al primo 401 se ne chiede uno
/// nuovo e si ripete la chiamata. Il token non si scrive in nessun file.
abstract final class _Token {
  static String valore = '';

  static Future<void> rinnova() async {
    final r = await Process.run(
        'cmd', ['/c', 'gcloud', 'auth', 'print-access-token']);
    final t = '${r.stdout}'.trim();
    if (t.isNotEmpty) valore = t;
  }
}

class _Conto {
  int chiamate = 0;
  int ingresso = 0;
  int uscita = 0;
}

/// **LA CHIAMATA VERA A VERTEX AI**, per REST, con la configurazione della
/// chiamata dell'app: stessa regione, stesso modello, ragionamento spento.
Future<String?> _vertex(String token, String modello, String istruzione,
    String testo, _Conto conto,
    {required double temperatura,
    required int tetto,
    required String mime,
    required Map<String, Object> schema}) async {
  const regione = LaDomandaCapita.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '$modello:generateContent');
  final corpo = {
    'systemInstruction': {
      'parts': [
        {'text': istruzione}
      ]
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': testo}
        ]
      }
    ],
    'generationConfig': {
      'temperature': temperatura,
      'maxOutputTokens': tetto,
      'responseMimeType': mime,
      'responseSchema': schema,
      'thinkingConfig': modello.startsWith('gemini-2.5')
          ? {'thinkingBudget': 0}
          : {'thinkingLevel': 'MINIMAL'},
    },
  };
  final client = HttpClient();
  try {
    conto.chiamate++;
    Future<(int, String)> chiama() async {
      final req = await client.postUrl(url);
      req.headers.set('Authorization', 'Bearer ${_Token.valore}');
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(corpo));
      final res = await req.close();
      return (res.statusCode, await res.transform(utf8.decoder).join());
    }

    var (stato, testoRisposta) = await chiama();
    if (stato == 401) {
      await _Token.rinnova();
      (stato, testoRisposta) = await chiama();
    }
    if (stato != 200) {
      throw HttpException('Vertex $stato: $testoRisposta');
    }
    final j = jsonDecode(testoRisposta) as Map<String, dynamic>;
    final uso = (j['usageMetadata'] as Map?) ?? const {};
    conto.ingresso += (uso['promptTokenCount'] as int?) ?? 0;
    conto.uscita += (uso['candidatesTokenCount'] as int?) ?? 0;
    return ((j['candidates'] as List).first['content']['parts'] as List)
        .first['text'] as String?;
  } finally {
    client.close();
  }
}

void _stampa(String colonna, List<_Esito> esiti) {
  print('');
  print('=== ORDINE DI VOCE 16, $colonna ===');
  for (final e in esiti) {
    final m = e.misura;
    print('${e.caso.nome.padRight(16)} '
        'A ${m.testiDistinti}/100 | '
        'B ${m.scheletriDistinti} (max ${m.quanteVolteLoScheletro}) | '
        'C ${(m.somiglianzaMassima * 100).toStringAsFixed(1)} tutte, '
        '${(m.somiglianzaFraDiverse * 100).toStringAsFixed(1)} senza simboli '
        'comuni | '
        'D ${m.quanteVolteIlParagrafo} | '
        'E ${e.pertinenti}/100 | '
        'scena dal modello ${e.dalModello}/100 | '
        'per blocco ${e.perBlocco} | richiamo in ${e.conRichiamo} | '
        'distanze gesto ${e.distanzaDelGesto} risposta ${e.distanzaDellaRisposta}'
        '${e.temi.isEmpty ? '' : ' | temi ${e.temi}'}'
        '${e.guasti.isEmpty ? '' : ' | guasti ${e.guasti}'}');
  }
  print('--- un responso per esteso, settima discesa di ${esiti.first.caso.nome}:');
  print(esiti.first.esempio);
  for (final e in esiti.where((e) => !e.passaC)) {
    print('--- coppia peggiore di ${e.caso.nome}, '
        '${(e.misura.somiglianzaMassima * 100).toStringAsFixed(1)} per cento:');
    print(e.misura.testoPeggioreUno);
    print('~~~');
    print(e.misura.testoPeggioreDue);
  }
}
