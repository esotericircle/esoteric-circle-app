// ignore_for_file: avoid_print
// **UN BANCO COL MODELLO VERO, NON UNA PROVA DEL RAMO.** Ordine FC voce
// 11.2, 5 ottobre 2026. Questi tre casi stavano in
// `test/la_prova_a_cento_discese_test.dart` e si saltavano a ogni giro
// senza `VERTEX_TOKEN`: chiamano Gemini davvero, costano, e misurano il
// modello. I casi senza rete restano in quella prova. Si lancia a mano:
//
//     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test tool/banchi_col_modello/la_prova_a_cento_discese_col_modello_test.dart
import 'dart:io';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../test/motore_della_ripetizione.dart';
import '../../test/la_prova_a_cento_discese_comune.dart';

void main() {
  // Fuori da test/ l'analisi non sa che questo e' un banco di prova.
  // ignore: invalid_use_of_visible_for_testing_member
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  TokenDiDiscesa.valore = token;

  test('CON RETE: le cinque misure su cento discese, col modello vero',
      () async {
    HttpOverrides.global = null;
    // **UNA DISCESA ALLA VOLTA**, come per una persona: la prima stesura
    // faceva girare gli undici casi insieme, undici chiamate contemporanee, e
    // la latenza sotto quel carico faceva scadere i due secondi di pazienza.
    final esiti = <EsitoDiDiscesa>[];
    // **I CASI SI POSSONO SCEGLIERE**, per nome e separati da virgole, in
    // `CASI_DELLA_PROVA`: una correzione su un caso solo si misura in pochi
    // minuti. Senza la variabile girano tutti.
    final scelti = (Platform.environment['CASI_DELLA_PROVA'] ?? '')
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toSet();
    for (final caso in casiDiDiscesa) {
      if (scelti.isNotEmpty && !scelti.contains(caso.nome)) continue;
      final e = await centoDiscese(caso, conRete: true, token: token);
      esiti.add(e);
      // **CASO PER CASO**, ordine DL voce 07: con i tre testi la prova dura
      // quasi un'ora, e un intoppo a meta' non deve portarsi via i conti.
      stampaDiDiscesa('CON RETE, ${caso.nome}', [e]);
    }
    stampaDiDiscesa('CON RETE', esiti);
    final chiamate = esiti.fold<int>(0, (s, e) => s + e.chiamate);
    final ingresso = esiti.fold<int>(0, (s, e) => s + e.tokenIngresso);
    final uscita = esiti.fold<int>(0, (s, e) => s + e.tokenUscita);
    print('CHIAMATE AL MODELLO: $chiamate, token in ingresso $ingresso, in '
        'uscita $uscita');
    for (final e in perTipoDiDiscesa.entries) {
      print('  ${e.key}: ${e.value.media}');
    }
    // **PRIMA E DOPO LA SECONDA CHIAMATA, SU TUTTE LE DISCESE**, ordine DQ
    // voce 06, e le righe riprese per motivo.
    final discese = esiti.length * MotoreDellaRipetizione.quante;
    for (final pezzo in ['titolo', 'risposta', 'gesto']) {
      final prima =
          esiti.fold<int>(0, (s, e) => s + (e.dalModelloPrima[pezzo] ?? 0));
      final dopo =
          esiti.fold<int>(0, (s, e) => s + (e.dalModelloDopo[pezzo] ?? 0));
      print(
          'DQ.06 $pezzo dal modello: prima ${(prima * 100 / discese).toStringAsFixed(1)}, '
          'dopo ${(dopo * 100 / discese).toStringAsFixed(1)} per cento, su $discese discese');
    }
    final riprese = <String, int>{};
    for (final e in esiti) {
      e.recuperatePerMotivo
          .forEach((k, v) => riprese[k] = (riprese[k] ?? 0) + v);
    }
    final ordinate = riprese.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    print('DQ.06 righe riprese alla seconda chiamata, per motivo della prima: '
        '${ordinate.map((e) => '${e.key} ${e.value}').join(', ')}');
    // **IL COSTO DI UNA DISCESA**, ai prezzi del catalogo Cloud Billing letti
    // nell'ordine DJ voce 03: Gemini 2.5 Flash 0,30 dollari per milione in
    // ingresso e 2,50 in uscita, Flash Lite 0,10 e 0,40.
    final scena = perTipoDiDiscesa['scena']!;
    final tema = perTipoDiDiscesa['tema']!;
    final dollari = (scena.ingresso * 0.30 +
            scena.uscita * 2.50 +
            tema.ingresso * 0.10 +
            tema.uscita * 0.40) /
        1e6;
    print('DQ.13 costo: ${(dollari / discese).toStringAsFixed(6)} dollari a '
        'discesa, ${scena.chiamate} chiamate della scena su $discese discese');
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 120)));

  test('CON RETE: G, venti cammini col modello vero', () async {
    HttpOverrides.global = null;
    final g = await misuraG(conRete: true, token: token);
    print('DQ.13 G CON RETE: ${g.cammini} cammini, ${g.ripetizioni.length} '
        'strati che ripetono, somiglianza peggiore '
        '${(g.peggiore * 100).toStringAsFixed(1)} per cento');
    for (final r in g.ripetizioni) {
      print('  $r');
    }
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 30)));

  test('CON RETE: il segno col modello vero, dodici domande', () async {
    HttpOverrides.global = null;
    const domande = [
      'Devo accettare il lavoro nuovo?',
      'Mi conviene aspettare ancora?',
      'Questa persona tornerà?',
      'Sto sbagliando strada?',
      'È il momento di partire?',
      'Posso fidarmi di lei?',
      'Devo dire di no?',
      'Ho visto tutto quello che serve?',
      'Faccio bene a restare?',
      'Riuscirò a finire in tempo?',
      'Devo cambiare casa quest\'anno?',
      'Mi sto perdendo qualcosa?',
    ];
    final gesti = <String, int>{};
    final scartati = <String>[];
    final righe = <String>[];
    final conto = ContoDiDiscesa();
    for (var i = 0; i < domande.length; i++) {
      final animale = AnimalCatalog.animals[i % AnimalCatalog.animals.length];
      final risposta = await vertexDiDiscesa(token, GestiDelSegno.modello,
          GestiDelSegno.istruzione(animale), domande[i], conto,
          tipo: 'segno',
          temperatura: 0.7,
          tetto: 256,
          mime: 'application/json',
          schema: {
            'type': 'OBJECT',
            'properties': {
              'gesto': {
                'type': 'STRING',
                'enum': [for (final g in GestoDelSegno.values) g.name],
              },
              'riga': {'type': 'STRING'},
            },
          });
      final segno = GestiDelSegno.leggi(risposta, animale);
      if (segno == null) {
        scartati.add('${animale.name}: $risposta');
        continue;
      }
      gesti[segno.gesto.name] = (gesti[segno.gesto.name] ?? 0) + 1;
      righe.add('${domande[i]} -> ${segno.riga}');
    }
    print('');
    print('=== ORDINE DJ VOCE 08, IL SEGNO COL MODELLO VERO ===');
    print('accettati ${righe.length} su ${domande.length}, gesti $gesti, '
        '${perTipoDiDiscesa['segno']!.media}');
    for (final r in righe) {
      print('  $r');
    }
    for (final s in scartati) {
      print('  SCARTATO $s');
    }
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 5)));
}
