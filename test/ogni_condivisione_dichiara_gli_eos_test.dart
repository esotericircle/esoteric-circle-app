import 'dart:io';

import 'package:esoteric_circle/core/condivisione/premio_della_condivisione.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// OGNI CONDIVISIONE DICHIARA GLI EOS, E LI PAGA DAVVERO. Ordine BG voce 04.
///
/// Parole del fondatore: "quando ho la risposta da una funzionalita' e
/// propone la condivisione, non dovrebbe indicarmi il numero di Eos che
/// guadagno? Controlla che sia cosi' come REGOLA per tutte le funzionalita'".
/// La regola era gia' sulle card dei traguardi (BB.04): adesso ogni punto
/// che condivide passa da `PremioDellaCondivisione`, che scrive il numero
/// del SERVER sul pulsante e paga a condivisione avvenuta, dentro lo stesso
/// tetto anti farming delle condivisioni premiate.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ogni punto che condivide porta il premio, enumerati', () {
    // I punti che passano dalla porta della condivisione, MENO i tre che
    // hanno gia' la loro economia o non devono averla: la celebrazione e la
    // card del traguardo (BB.04, coi loro tre modi), e lo scarico dei
    // propri dati (condividere i propri dati con se stessi non e' un gesto
    // da premiare).
    final esenti = {
      'lib/features/sigilli/celebrazione.dart',
      'lib/features/account/account_screen.dart',
    };
    final senzaPremio = <String>[];
    for (final f in fileScoperti('lib/features',
        minimo: quantiFileHannoLeFunzioni, estensione: '.dart')) {
      final percorso = f.path.replaceAll('\\', '/');
      if (esenti.contains(percorso)) continue;
      // **SI GUARDA IL CODICE, NON I COMMENTI, e il buco l'ha trovato
      // l'ordine CG.** Un file che SPIEGA come funziona la condivisione
      // nomina `PortaDellaCondivisione` in una riga di documentazione, e
      // questa guardia lo accusava di condividere senza pagare il premio:
      // e' successo ad `azioni_del_responso.dart`, che la condivisione non
      // la fa, la delega a chi gliela passa. Si tolgono i commenti prima di
      // cercare.
      final testo = f.readAsLinesSync().where((r) {
        final t = r.trimLeft();
        return !t.startsWith('//') && !t.startsWith('*') && !t.startsWith('/*');
      }).join('\n');
      if (!testo.contains('PortaDellaCondivisione.')) continue;
      // Gli AIUTANTI delle card non hanno un contesto: restituiscono
      // l'esito vero della porta (return PortaDellaCondivisione...) e il
      // premio lo paga il chiamante, che il blocco qui sotto enumera.
      if (testo.contains('return PortaDellaCondivisione.')) continue;
      if (!testo.contains('PremioDellaCondivisione.premia')) {
        senzaPremio.add(percorso);
      }
    }
    expect(senzaPremio, isEmpty,
        reason: 'questi punti condividono senza dichiarare ne\' pagare il '
            'premio: $senzaPremio');

    // E i chiamanti degli aiutanti pagano, uno per uno.
    const chiamanti = [
      'lib/features/horoscope/oroscopo_screen.dart',
      'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
      'lib/features/maestri/aura/face/face_constellation_screen.dart',
      'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
      'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
      'lib/features/tarot/stesa_tre_carte_screen.dart',
      'lib/features/rituals/dream_rite_screen.dart',
      'lib/features/rituals/sunset_rune_screen.dart',
      'lib/features/synastry/sinastria_vip_screen.dart',
    ];
    for (final percorso in chiamanti) {
      expect(
          File(percorso)
              .readAsStringSync()
              .contains('PremioDellaCondivisione.premia'),
          isTrue,
          reason: '$percorso condivide una card e non paga il premio');
    }
  });

  testWidgets('il pulsante dice il numero del server, e tace oltre il tetto',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaDelPremio());
    await borsa.sincronizza();
    late String conPremio;
    late String base;
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: borsa,
      child: Builder(builder: (context) {
        conPremio = PremioDellaCondivisione.etichetta(context);
        base = PremioDellaCondivisione.etichetta(context,
            base: 'Condividi il tuo cielo');
        return const SizedBox.shrink();
      }),
    ));
    expect(conPremio, 'Condividi · +15 Eos',
        reason: 'il pulsante non dichiara il numero del server');
    expect(base, 'Condividi il tuo cielo · +15 Eos');

    // Al tetto raggiunto la promessa tace: il server non pagherebbe.
    borsa.condivisionePremiata();
    borsa.condivisionePremiata();
    borsa.condivisionePremiata();
    late String alTetto;
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: borsa,
      child: Builder(builder: (context) {
        alTetto = PremioDellaCondivisione.etichetta(context);
        return const SizedBox.shrink();
      }),
    ));
    expect(alTetto, 'Condividi',
        reason: 'oltre il tetto il pulsante promette un premio che il '
            'server non paga');
  });
}

class _PortaDelPremio extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 300,
        'listinoDellaCondivisione': const {
          'invito_con_download': 60,
          'social_pubblico': 30,
          'condivisione_privata': 15,
          'condivisione_arte': 15,
        },
      });

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      315;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}
