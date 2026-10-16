// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/lunario/il_listino_del_respiro.dart';
import 'package:esoteric_circle/features/respiro_della_luna/gli_eos_del_respiro.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_piano_del_respiro.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **IL RESPIRO DELLA LUNA: IL SOCIALE E I PIANI.** Ordine FX voci FX.09 e
/// FX.10, 16 ottobre 2026.
///
/// FX.10: il Viandante ha solo il gratuito (la Luna di quest'ora, il
/// respiro di oggi, la perla del giorno, il tempo sotto il dito sulle 24
/// ore di oggi); l'Iniziato ha in più la collana completa, lo scrigno e gli
/// avvisi, e il tempo sotto il dito su tutto il mese; l'Adepto e
/// l'Illuminato hanno in più Respiriamo insieme.
///
/// FX.09: il respiro collettivo (il conteggio e gli amici) e la collana a
/// due (l'invito, la risposta, il segnale del giorno) sul solo client: le
/// porte del server sono scritte e non pubblicate (R3 dell'ordine), e qui
/// si prova che il telefono le chiami con la forma giusta.
class _PortaDelRespiro extends PortaFintaDelCerchioSociale {
  Map<String, Object?>? conteggioDaRestituire;
  List<Map<String, Object?>>? collaneDaRestituire;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'respiroInsiemeConteggio' && conteggioDaRestituire != null) {
      chieste.add((porta, corpo));
      return EsitoSociale(dati: conteggioDaRestituire!);
    }
    if (porta == 'leCollaneADue' && collaneDaRestituire != null) {
      chieste.add((porta, corpo));
      return EsitoSociale(dati: {'collane': collaneDaRestituire});
    }
    return super.sociale(porta, corpo);
  }
}

void main() {
  group('FX.10 i piani del Respiro della Luna', () {
    test(
        'il Viandante non ha nulla oltre il gratuito; dall\'Iniziato la '
        'collana completa, lo scrigno, gli avvisi e il mese; dall\'Adepto '
        'Respiriamo insieme', () {
      for (final t in Tier.values) {
        print('FX.10 MISURA ${t.name}: collana '
            '${IlPianoDelRespiro.collanaCompletaAperta(t)}, avvisi '
            '${IlPianoDelRespiro.avvisiAperti(t)}, mese '
            '${IlPianoDelRespiro.tempoSottoIlDitoSuTuttoIlMese(t)}, insieme '
            '${IlPianoDelRespiro.respiroInsiemeAperto(t)}');
      }
      expect(IlPianoDelRespiro.collanaCompletaAperta(Tier.free), isFalse);
      expect(IlPianoDelRespiro.avvisiAperti(Tier.free), isFalse);
      expect(
          IlPianoDelRespiro.tempoSottoIlDitoSuTuttoIlMese(Tier.free), isFalse);
      expect(IlPianoDelRespiro.respiroInsiemeAperto(Tier.free), isFalse);

      expect(IlPianoDelRespiro.collanaCompletaAperta(Tier.tier1), isTrue);
      expect(IlPianoDelRespiro.avvisiAperti(Tier.tier1), isTrue);
      expect(
          IlPianoDelRespiro.tempoSottoIlDitoSuTuttoIlMese(Tier.tier1), isTrue);
      expect(IlPianoDelRespiro.respiroInsiemeAperto(Tier.tier1), isFalse,
          reason: 'Respiriamo insieme e\' esclusiva dell\'Adepto');

      expect(IlPianoDelRespiro.collanaCompletaAperta(Tier.tier2), isTrue);
      expect(IlPianoDelRespiro.respiroInsiemeAperto(Tier.tier2), isTrue);
      expect(IlPianoDelRespiro.collanaCompletaAperta(Tier.tier3), isTrue);
      expect(IlPianoDelRespiro.respiroInsiemeAperto(Tier.tier3), isTrue);

      // Le voci chiuse dicono da quale piano si aprono (mai un vicolo cieco).
      expect(
          PlanCatalog.dalPiano(
              (t) => PlanCatalog.apre(RigaDelPiano.respiroInsieme, t)),
          'Dall’Adepto');
      expect(
          PlanCatalog.dalPiano((t) =>
              PlanCatalog.apre(RigaDelPiano.respiroCollanaCompleta, t)),
          'Dall’Iniziato');
    });

    test('ogni riga del Respiro della Luna compare una volta sola nella matrice',
        () {
      final chiavi = [
        RigaDelPiano.respiroCollanaCompleta,
        RigaDelPiano.respiroAvvisi,
        RigaDelPiano.respiroTempoSottoIlDitoMese,
        RigaDelPiano.respiroInsieme,
      ];
      for (final c in chiavi) {
        final volte =
            PlanCatalog.matrix.where((r) => r.chiave == c).length;
        expect(volte, 1, reason: '${c.name} deve comparire una volta sola');
      }
    });
  });

  group('FX.10 il listino del Respiro della Luna', () {
    test(
        'la perla ricucita, l\'assaggio di Respiriamo insieme e la collana a '
        'due in più hanno i prezzi dichiarati', () {
      expect(ListinoDegliEos.perlaRicucita.costo, 25,
          reason: 'lo stesso numero di IlListinoDelRespiro.costoRicucituraInEos, '
              'scritto da un altro agente dello stesso ordine FX (voce FX.05)');
      expect(ListinoDegliEos.perlaRicucita.costo,
          IlListinoDelRespiro.costoRicucituraInEos,
          reason: 'i due listini non devono mai divergere su questo prezzo');
      expect(ListinoDegliEos.respiroInsiemeUnaVolta.costo, 40);
      expect(ListinoDegliEos.collanaADueUnaVolta.costo, 50,
          reason: 'lo stesso prezzo esatto della proposta insieme del lunario');
      expect(ListinoDegliEos.collanaADueUnaVolta.costo,
          ListinoDegliEos.propostaInsiemeDelLunario.costo);
      expect(ListinoDegliEos.tutte, contains(ListinoDegliEos.perlaRicucita));
      expect(
          ListinoDegliEos.tutte, contains(ListinoDegliEos.respiroInsiemeUnaVolta));
      expect(
          ListinoDegliEos.tutte, contains(ListinoDegliEos.collanaADueUnaVolta));
    });
  });

  group('FX.10 il portafoglio a Eos del Respiro della Luna', () {
    test('legge zero finche\' nessun acquisto arriva, poi tiene il conto e lo '
        'ritrova dopo la riapertura', () async {
      SharedPreferences.setMockInitialValues({});
      final wallet = GliEosDelRespiro();
      await wallet.leggi();
      expect(wallet.perleRicucite, 0);
      expect(wallet.assaggiRespiroInsieme, 0);
      expect(wallet.collaneADueComprate, 0);

      await wallet.aggiungiUnaPerlaRicucita();
      await wallet.aggiungiUnAssaggioDiRespiroInsieme();
      await wallet.aggiungiUnaCollanaADue();
      await wallet.aggiungiUnaCollanaADue();
      expect(wallet.perleRicucite, 1);
      expect(wallet.assaggiRespiroInsieme, 1);
      expect(wallet.collaneADueComprate, 2);

      final secondaLettura = GliEosDelRespiro();
      await secondaLettura.leggi();
      expect(secondaLettura.perleRicucite, 1,
          reason: 'il portafoglio sopravvive alla riapertura dell\'app');
      expect(secondaLettura.collaneADueComprate, 2);

      expect(secondaLettura.consumaUnaPerlaRicucita(), isTrue);
      expect(secondaLettura.perleRicucite, 0);
      expect(secondaLettura.consumaUnaPerlaRicucita(), isFalse,
          reason: 'non si consuma cio\' che non c\'e\'');
      expect(secondaLettura.consumaUnaCollanaADue(), isTrue);
      expect(secondaLettura.collaneADueComprate, 1);
    });
  });

  group('FX.09 il Respiro della Luna nel Cerchio sociale', () {
    test('respiroInsiemeEntra chiama la porta vera, senza corpo in più',
        () async {
      final porta = _PortaDelRespiro();
      final sociale = IlCerchioSociale(porta: porta);
      final esito = await sociale.respiroInsiemeEntra();
      expect(esito.ok, isTrue);
      expect(porta.chieste.last.$1, 'respiroInsiemeEntra');
    });

    test(
        'respiroInsiemeConteggio legge quante persone e quali amici sono '
        'dentro', () async {
      final porta = _PortaDelRespiro()
        ..conteggioDaRestituire = {
          'ok': true,
          'quante': 42,
          'amiciDentro': ['u-stella', 'u-ambra'],
        };
      final sociale = IlCerchioSociale(porta: porta);
      final stato = await sociale.respiroInsiemeConteggio();
      expect(stato, isNotNull);
      print('FX.09 MISURA il respiro insieme: ${stato!.quante} persone, '
          'amici dentro ${stato.amiciDentro}');
      expect(stato.quante, 42);
      expect(stato.amiciDentro, ['u-stella', 'u-ambra']);
    });

    test(
        'respiroInsiemeConteggio col Cerchio spento non risponde: nullo, e '
        'nessun gesto si finge riuscito', () async {
      final sociale = IlCerchioSociale(porta: const PortaSpentaDelCerchio());
      final stato = await sociale.respiroInsiemeConteggio();
      expect(stato, isNull);
    });

    test('invitaCollanaADue manda l\'amico e il ciclo in forma AAAA-MM-GG',
        () async {
      final porta = _PortaDelRespiro();
      final sociale = IlCerchioSociale(porta: porta);
      final esito = await sociale.invitaCollanaADue(
          amico: 'u-stella', ciclo: DateTime(2026, 11, 24));
      expect(esito.ok, isTrue);
      final chiesta =
          porta.chieste.singleWhere((c) => c.$1 == 'invitaCollanaADue').$2;
      expect(chiesta['amico'], 'u-stella');
      expect(chiesta['ciclo'], '2026-11-24');
    });

    test('rispondiCollanaADue manda id e risposta, e ricarica il Cerchio',
        () async {
      final porta = _PortaDelRespiro();
      final sociale = IlCerchioSociale(porta: porta);
      final esito =
          await sociale.rispondiCollanaADue('coll1', risposta: 'accetta');
      expect(esito.ok, isTrue);
      final chiesta =
          porta.chieste.singleWhere((c) => c.$1 == 'rispondiCollanaADue').$2;
      expect(chiesta['id'], 'coll1');
      expect(chiesta['risposta'], 'accetta');
      expect(porta.chieste.any((c) => c.$1 == 'ilMioCerchio'), isTrue,
          reason: 'un esito positivo ricarica lo stato del Cerchio');
    });

    test(
        'segnalaRespiroDelGiornoPerLaCollanaADue manda il giorno in forma '
        'AAAA-MM-GG', () async {
      final porta = _PortaDelRespiro();
      final sociale = IlCerchioSociale(porta: porta);
      await sociale.segnalaRespiroDelGiornoPerLaCollanaADue(
          giorno: DateTime(2026, 11, 20));
      final chiesta = porta.chieste
          .singleWhere((c) => c.$1 == 'segnalaRespiroDelGiornoPerLaCollanaADue')
          .$2;
      expect(chiesta['giorno'], '2026-11-20');
    });

    test(
        'FXA.03 ricuciUnaPerlaDelRespiro manda giorno, inizio del ciclo e un '
        'identificativo del movimento, mai il prezzo', () async {
      final porta = _PortaDelRespiro();
      final sociale = IlCerchioSociale(porta: porta);
      final consenso = ConsensoDellaSpesa.perLeProve(
          ListinoDegliEos.perlaRicucita.costo);
      await sociale.ricuciUnaPerlaDelRespiro(
          consenso: consenso,
          giorno: DateTime(2026, 10, 12),
          inizioCiclo: DateTime(2026, 10, 10));
      await sociale.ricuciUnaPerlaDelRespiro(
          consenso: consenso,
          giorno: DateTime(2026, 10, 12),
          inizioCiclo: DateTime(2026, 10, 10));
      final chieste = [
        for (final c in porta.chieste)
          if (c.$1 == 'ricuciUnaPerlaDelRespiro') c.$2,
      ];
      print('FXA.03 MISURA la ricucitura dal telefono: chiamate '
          '${chieste.length}, campi ${chieste.first.keys.toList()}');
      expect(chieste, hasLength(2));
      expect(chieste.first['giorno'], '2026-10-12');
      expect(chieste.first['inizioCiclo'], '2026-10-10');
      expect(chieste.first.keys.toSet(),
          {'idMovimento', 'giorno', 'inizioCiclo'},
          reason: 'il prezzo lo decide il server, dal telefono non viaggia');
      expect('${chieste.first['idMovimento']}', startsWith('respiro_ricucitura'));
      expect(chieste.first['idMovimento'], isNot(chieste.last['idMovimento']),
          reason: 'ogni gesto porta il suo movimento: il giorno ripetuto lo '
              'rende innocuo il server, non un identificativo riusato');
    });

    test('leCollaneADue legge l\'elenco, con l\'altra persona e i giorni accesi',
        () async {
      final porta = _PortaDelRespiro()
        ..collaneDaRestituire = [
          {
            'id': 'coll1',
            'ciclo': '2026-11-24',
            'con': 'u-stella',
            'stato': 'attiva',
            'daMe': true,
            'giorniAccesi': ['2026-11-20'],
          },
        ];
      final sociale = IlCerchioSociale(porta: porta);
      final collane = await sociale.leCollaneADue();
      expect(collane, hasLength(1));
      expect(collane.single.conUid, 'u-stella');
      expect(collane.single.stato, 'attiva');
      expect(collane.single.iniziataDaMe, isTrue);
      expect(collane.single.giorniAccesi, ['2026-11-20']);
    });
  });
}
