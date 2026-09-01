/// LE PUSH DEI DONI. Ordine CG voce 16.
///
/// Le cinque prove del rosso che l'ordine chiede, piu' il censimento degli
/// interruttori: **elenchi di interruttori delle notifiche nell'app: UNO.**
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/rituals/custode_delle_push.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/prova_delle_push.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/services/push/porta_delle_push.dart';

/// Una porta che non tocca la rete e conta cosa le passa davanti.
class _PortaContata extends PortaDelleScelte {
  final List<ScelteDaMandare> mandate = [];
  int tolte = 0;
  bool rispondiDiSi = true;

  @override
  Future<bool> manda(ScelteDaMandare scelte) async {
    mandate.add(scelte);
    return rispondiDiSi;
  }

  @override
  Future<bool> togli() async {
    tolte++;
    return true;
  }
}

const _adesso = 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  // ---------------------------------------------------------------- a)
  test('CG.16 a: a un Viandante fuori dalla prova non parte nessuna push', () {
    final registrato = DateTime(2026, 1, 1);
    final dopoLaProva =
        registrato.add(const Duration(days: ProvaDellePush.giorniDiProva + 1));

    expect(
        ProvaDellePush.riceveLePush(
            tier: Tier.free, registratoIl: registrato, adesso: dopoLaProva),
        isFalse,
        reason: 'chi non paga e ha finito la prova non riceve push. IL ROSSO '
            'SI DIMOSTRA togliendo il controllo del piano, e questa torna '
            'vera');
    expect(
        ProvaDellePush.diritto(
            tier: Tier.free, registratoIl: registrato, adesso: dopoLaProva),
        DirittoAllePush.soloChiamateLocali,
        reason: 'e non resta senza niente: le chiamate locali sono accese e '
            'gratuite per tutti');
  });

  test('CG.16 a: chi non si e\' mai registrato non ha nemmeno cominciato', () {
    expect(
        ProvaDellePush.riceveLePush(
            tier: Tier.free, registratoIl: null, adesso: DateTime(2026, 8, 31)),
        isFalse,
        reason: 'la prova parte dalla PRIMA REGISTRAZIONE: senza, non e\' '
            'ancora cominciata');
  });

  // ---------------------------------------------------------------- b)
  test(
      'CG.16 b: dentro il mese di prova la push parte, e il confine e\' esatto',
      () {
    final registrato = DateTime(2026, 1, 1);

    // Il primo giorno.
    expect(
        ProvaDellePush.riceveLePush(
            tier: Tier.free, registratoIl: registrato, adesso: registrato),
        isTrue);

    // **IL CONFINE, giorno per giorno.** L'errore che questa prova cerca e' lo
    // scarto di UN GIORNO: un `>` invece di un `>=` regalerebbe a tutti un
    // giorno in piu' di prova, e nessuno se ne accorgerebbe mai.
    final ultimoBuono =
        registrato.add(const Duration(days: ProvaDellePush.giorniDiProva - 1));
    final primoFuori =
        registrato.add(const Duration(days: ProvaDellePush.giorniDiProva));

    expect(
        ProvaDellePush.riceveLePush(
            tier: Tier.free, registratoIl: registrato, adesso: ultimoBuono),
        isTrue,
        reason: 'il giorno ${ProvaDellePush.giorniDiProva} e\' ancora dentro');
    expect(
        ProvaDellePush.riceveLePush(
            tier: Tier.free, registratoIl: registrato, adesso: primoFuori),
        isFalse,
        reason: 'il giorno ${ProvaDellePush.giorniDiProva + 1} e\' fuori. IL '
            'ROSSO SI DIMOSTRA sbagliando il confine di un giorno');

    expect(
        ProvaDellePush.giorniRimasti(
            registratoIl: registrato, adesso: registrato),
        ProvaDellePush.giorniDiProva);
    expect(
        ProvaDellePush.giorniRimasti(
            registratoIl: registrato, adesso: primoFuori),
        0,
        reason: 'i giorni rimasti non vanno mai sotto zero');
  });

  test('CG.16: un abbonato ha le push senza prova, e a qualunque data', () {
    for (final tier in const [Tier.tier1, Tier.tier2, Tier.tier3]) {
      expect(
          ProvaDellePush.riceveLePush(
              tier: tier,
              registratoIl: DateTime(2020, 1, 1),
              adesso: DateTime(2026, 8, 31)),
          isTrue,
          reason: 'il piano $tier paga, quindi la prova non c\'entra');
      expect(
          ProvaDellePush.diritto(
              tier: tier, registratoIl: null, adesso: DateTime(2026, 8, 31)),
          DirittoAllePush.abbonato);
    }
    expect(ProvaDellePush.pianoMinimo, Tier.tier1,
        reason: 'premium dal primo piano a pagamento in su, parole '
            'dell\'ordine');
  });

  // ---------------------------------------------------------------- c)
  test('CG.16 c: UN SOLO elenco di interruttori, e passano tutti da li\'', () {
    // **Il vincolo dell'ordine**: "le push si accendono e si spengono dalle
    // STESSE cinque scelte di SceltaDegliAvvisi, con le STESSE ore. Non nasce
    // un secondo elenco di interruttori."
    final fuori = <String>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      // La casa delle scelte e' l'unica che puo' scrivere le sue chiavi.
      if (percorso.endsWith('lib/core/rituals/scelta_degli_avvisi.dart')) {
        continue;
      }
      final sorgente = voce.readAsStringSync();
      // Chi scrive una chiave `rituale.` sta creando un secondo interruttore.
      if (RegExp(r"setBool\(\s*'rituale\.").hasMatch(sorgente) ||
          RegExp(r"setInt\(\s*'rituale\.").hasMatch(sorgente)) {
        fuori.add(percorso);
      }
    }
    // ignore: avoid_print
    print('ORDINE CG VOCE 16: elenchi di interruttori degli avvisi fuori '
        'dalla casa comune ${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'questi punti accendono o spengono un avviso per conto loro: '
            '$fuori. IL ROSSO SI DIMOSTRA creando un secondo interruttore');
  });

  test('CG.16 c: le push leggono le STESSE scelte e le STESSE ore', () async {
    final porta = _PortaContata();
    final custode = CustodeDellePush(porta: porta);
    await custode.carica();
    await custode.tokenNuovo('un-token-lungo-abbastanza-per-passare');

    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    await scelta.scegliLOra(DailyElement.dawn, ora: 6, minuto: 30);

    final mandato =
        await custode.sincronizza(scelta: scelta, fuso: 'Europe/Rome');
    expect(mandato, isTrue);
    expect(porta.mandate, hasLength(1));
    expect(porta.mandate.first.doni['dawn'], 6 * 60 + 30,
        reason: 'l\'ora che va al server e\' quella che la persona ha scelto '
            'nel menu\' che esiste, non una seconda ora scritta per le push');
    expect(porta.mandate.first.fuso, 'Europe/Rome',
        reason: 'senza il fuso il server spingerebbe a tutti all\'ora di Roma');
  });

  test('CG.16: non si sincronizza se niente e\' cambiato', () async {
    final porta = _PortaContata();
    final custode = CustodeDellePush(porta: porta);
    await custode.carica();
    await custode.tokenNuovo('un-token-lungo-abbastanza-per-passare');
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();

    expect(
        await custode.sincronizza(scelta: scelta, fuso: 'Europe/Rome'), isTrue);
    expect(
        await custode.sincronizza(scelta: scelta, fuso: 'Europe/Rome'), isFalse,
        reason: 'chi apre la pagina e non cambia niente non deve far partire '
            'nessuna scrittura');
    expect(porta.mandate, hasLength(1));

    // E un cambio vero riparte.
    await scelta.scegliLOra(DailyElement.night, ora: 23, minuto: 0);
    expect(
        await custode.sincronizza(scelta: scelta, fuso: 'Europe/Rome'), isTrue);
    expect(porta.mandate, hasLength(2));
  });

  test('CG.16: il token nuovo si tiene, ed e\' la cura di quello che scade',
      () async {
    final custode = CustodeDellePush();
    await custode.carica();
    expect(custode.token, isNull);
    await custode.tokenNuovo('primo-token-abbastanza-lungo-per-passare');
    expect(custode.token, 'primo-token-abbastanza-lungo-per-passare');
    // La rigenerazione: senza questa via il server spingerebbe verso un
    // indirizzo morto e la persona smetterebbe di ricevere senza accorgersene.
    await custode.tokenNuovo('secondo-token-abbastanza-lungo-per-passare');
    expect(custode.token, 'secondo-token-abbastanza-lungo-per-passare');
  });

  // ---------------------------------------------------------------- e)
  test('CG.16 e: il token se ne va con la cancellazione dell\'account',
      () async {
    final porta = _PortaContata();
    final custode = CustodeDellePush(porta: porta);
    await custode.carica();
    await custode.tokenNuovo('un-token-lungo-abbastanza-per-passare');
    expect(custode.token, isNotNull);

    await custode.dimentica();

    expect(custode.token, isNull, reason: 'il token deve sparire dal telefono');
    expect(porta.tolte, 1, reason: 'e anche dal server');

    // E il prefisso deve essere fra quelli che la cancellazione porta via.
    expect(CioCheETuo.prefissi, contains(CustodeDellePush.prefisso),
        reason: 'il prefisso ${CustodeDellePush.prefisso} non e\' in '
            'CioCheETuo: il token sopravvivrebbe a chi ha chiesto di sparire. '
            'IL ROSSO SI DIMOSTRA togliendolo da quell\'elenco');
  });

  // ---------------------------------------------------------------- 6)
  test('CG.16 punto 6: la matrice ha la riga delle push', () {
    final riga = PlanCatalog.matrix
        .where((r) => r.label.toLowerCase().contains('notifiche'))
        .toList();
    expect(riga, hasLength(1),
        reason: 'la riga delle notifiche push non c\'e\' nella matrice, '
            'oppure ce ne sono due');
    // ignore: avoid_print
    print('ORDINE CG VOCE 16: la riga delle notifiche dice '
        '${riga.first.values}');
    expect(riga.first.values, hasLength(4));
    expect(riga.first.values[0].toLowerCase(), contains('prova'),
        reason: 'al Viandante la riga deve dire che c\'e\' un mese di prova');
    for (final i in const [1, 2, 3]) {
      expect(riga.first.values[i].toLowerCase(), isNot(contains('no')),
          reason: 'dall\'Iniziato in su le push ci sono');
    }
  });

  test('CG.16 punto 3: nessuna promessa che le locali si spengano', () {
    // **Vincolo esplicito dell'ordine**: in nessun caso le locali si spengono
    // per chi le push non le ha.
    final sorgente =
        File('lib/core/rituals/prova_delle_push.dart').readAsStringSync();
    expect(sorgente.contains('soloChiamateLocali'), isTrue);
    expect(ProvaDellePush.invitoDopoLaProva.contains('restano'), isTrue,
        reason: 'chi finisce la prova deve leggere che gli avvisi del '
            'telefono restano: non e\' un vicolo cieco');
  });

  test('CG.16 punto 1: il permesso e\' lo STESSO delle chiamate locali', () {
    // **Verificato sul manifesto vero, non creduto.** L'ordine dice che su
    // Android 13 e oltre il permesso delle push e' lo stesso che le chiamate
    // locali chiedono gia': se fosse un secondo permesso, la persona vedrebbe
    // due richieste per la stessa cosa.
    final manifesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final quanti = RegExp('POST_NOTIFICATIONS').allMatches(manifesto).length;
    // ignore: avoid_print
    print('ORDINE CG VOCE 16: POST_NOTIFICATIONS dichiarato $quanti volta nel '
        'manifesto Android');
    expect(quanti, 1,
        reason: 'il permesso deve esserci UNA volta sola: zero vorrebbe dire '
            'che le push non arrivano su Android 13 e oltre, due che qualcuno '
            'lo ha dichiarato una seconda volta per le push');
  });

  test('CG.16: il mese di prova dura trenta giorni, e la ragione e\' scritta',
      () {
    expect(ProvaDellePush.giorniDiProva, 30);
    final sorgente =
        File('lib/core/rituals/prova_delle_push.dart').readAsStringSync();
    expect(sorgente.contains('PRIMA REGISTRAZIONE'), isTrue,
        reason: 'la decisione delegata dal fondatore deve essere scritta: '
            'installazione oppure registrazione');
    expect(_adesso, 0);
  });
}
