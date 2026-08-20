import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// I GRADINI DORMIENTI SONO DICHIARATI, NON FINTI. Ordine AR voce 05.
///
/// **Cos'e' un dormiente.** Una voce del Cammino che oggi NON si puo'
/// raggiungere, perche' chiede un gesto che l'app non registra (la meditazione
/// non ha una fine) o un motore che non esiste (le eclissi) o un dettaglio che
/// nessuna scena manda (la fase lunare col gesto). Non si toglie e non si
/// finge: resta nel dato, col suo perche' scritto dentro.
///
/// **Le tre cose che questa guardia pretende.** Un dormiente non arma mai, non
/// accredita mai, e la scala non si blocca su di lui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dormienti =
      Sentieri.tuttiITraguardi.where((t) => t.dormiente).toList();

  test('i dormienti esistono, sono dichiarati e portano il perche', () {
    // ignore: avoid_print
    print('ORDINE AR VOCE 05: dormienti ${dormienti.length} su '
        '${Sentieri.tuttiITraguardi.length}');
    expect(dormienti, isNotEmpty,
        reason: 'nessun dormiente: o il corpus non ne ha piu, o qualcuno li ha '
            'fatti sparire invece di dichiararli');
    for (final t in dormienti) {
      expect(t.condizione, isA<Dormiente>(),
          reason: '${t.id} e marcato dormiente ma porta una condizione vera: '
              'potrebbe accendersi per sbaglio');
      final perche = (t.condizione as Dormiente).perche;
      expect(perche.length, greaterThan(20),
          reason: '${t.id} dorme senza dire perche, e nessuno sapra mai cosa '
              'manca per svegliarlo');
    }
  });

  test('un dormiente non si accende, qualunque cosa succeda', () async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    // Uno stato pieno di tutto: gesti a migliaia, ogni evento del cielo, ogni
    // pezzo dell'identita. Se un dormiente potesse accendersi, si
    // accenderebbe qui.
    final stato = StatoDelCammino(
      gestiCompiuti: {
        for (final g in const [
          'alba', 'soffio', 'oracolo', 'stesa', 'gettata', 'tramonto',
          'sogno', 'sigillo', 'sinastria', 'oroscopo', 'viso', 'archetipo',
          'presenza', 'meditazione', 'chakra',
        ])
          g: 9999,
      },
      giorniConGesto: {'oracolo': 999, 'stesa': 999},
      seriePerRito: {'presenza': 999, 'oracolo': 999, 'alba': 999},
      valoriDistinti: {'stesa.carte': 78, 'tramonto.runa': 24},
      massimeRipetizioni: {'stesa.carte': 99},
      gradiniAlleSpalle: {'costellazione': 54, 'albero': 54, 'loto': 54},
      giorniDalPrimoGiorno: 3650,
    );
    final accesi = await diario.quelliCheSiAccendono(stato);
    final dormientiAccesi =
        accesi.where((t) => t.dormiente).map((t) => t.id).toList();
    // ignore: avoid_print
    print('ORDINE AR VOCE 05: con uno stato pieno di tutto si accendono '
        '${accesi.length} traguardi, dei quali dormienti '
        '${dormientiAccesi.length}');
    expect(dormientiAccesi, isEmpty,
        reason: 'questi dormienti si sono accesi: $dormientiAccesi');
  });

  test('la scala non si blocca su un dormiente', () async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    for (final s in Sentiero.values) {
      // Si accendono tutti i traguardi fino al primo dormiente del sentiero.
      final voci = Sentieri.di(s).toList()
        ..sort((a, b) => a.posizione.compareTo(b.posizione));
      final primoDormiente = voci.indexWhere((t) => t.dormiente);
      if (primoDormiente < 0) continue;
      for (var i = 0; i < primoDormiente; i++) {
        await diario.accendi(voci[i].id);
      }
      final prossimo = diario.prossimoDi(s);
      // ignore: avoid_print
      print('ORDINE AR VOCE 05: su ${s.name} il primo dormiente e '
          '${voci[primoDormiente].id}, e il prossimo proposto e '
          '${prossimo?.id}');
      expect(prossimo, isNotNull,
          reason: 'la scala di ${s.name} si e fermata su un dormiente: il '
              'sentiero e diventato un vicolo cieco');
      expect(prossimo!.dormiente, isFalse,
          reason: 'la scala di ${s.name} arma un dormiente: quel gradino non '
              'si accendera mai e il cammino resta li');
    }
  });

  test('il perche di ogni dormiente e scritto anche nel corpus o nel codice',
      () {
    // Il rapporto dell'ordine elenca i dormienti: questa riga pretende che il
    // generatore continui a scrivere il motivo dentro il dato, cosi' chi
    // legge il file dei sentieri sa cosa manca senza cercare altrove.
    final sorgente =
        File('lib/core/sigilli/sentiero_loto.dart').readAsStringSync();
    expect(sorgente.contains('Dormiente('), isTrue,
        reason: 'i dormienti non sono piu visibili nel dato generato');
  });

  test('le serrature sono DUE, e si sorvegliano tutte e due', () {
    // **PERCHE' DUE.** La prima e' la condizione stessa, che risponde falso a
    // qualunque stato; la seconda e' il salto nel motore. Togliendone una
    // sola il dormiente resta spento, ed e' il punto della difesa in
    // profondita': ma allora nessuna prova di comportamento puo' accorgersi
    // che una delle due e sparita. Questa riga guarda la seconda.
    final motore =
        File('lib/core/sigilli/diario_del_cammino.dart').readAsStringSync();
    expect(motore.contains('if (traguardo.dormiente) continue;'), isTrue,
        reason: 'la seconda serratura e sparita: se un domani un dormiente '
            'ricevesse per sbaglio una condizione vera, si accenderebbe');
    expect(motore.contains('!t.dormiente'), isTrue,
        reason: 'la scala non scavalca piu i dormienti: il sentiero puo '
            'fermarsi su un gradino che non si raggiunge mai');
  });
}
