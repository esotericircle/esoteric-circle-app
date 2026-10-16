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

  final dormienti = Sentieri.tuttiITraguardi.where((t) => t.dormiente).toList();

  test('i dormienti, quanti sono, sono dichiarati e portano il perche', () {
    // **ZERO, ED E' LA NOTIZIA. Ordine CP voce 06, 3 settembre 2026.**
    // La revisione E del corpus ne aveva **cinquantuno su centosessantacinque**,
    // cioe' quasi un terzo del Cammino chiedeva un gesto che nessuna schermata
    // manda o un motore che non esiste. La revisione F ne ha **zero**: e'
    // costruita solo sui venti gesti che hanno una schermata e sui
    // trentuno eventi che il motore del cielo calcola davvero.
    //
    // **La pretesa qui e' cambiata di verso, e va detto.** Prima diceva "ce
    // ne sono, e sono dichiarati"; adesso dice "se ce ne sono, sono
    // dichiarati col loro perche'". Su un insieme vuoto una pretesa cosi'
    // sarebbe muta, ed e' per questo che il numero si STAMPA e che la prova
    // qui sotto costruisce un dormiente a mano per verificare che la
    // serratura tenga ancora.
    // ignore: avoid_print
    print('ORDINE CP VOCE 06: dormienti ${dormienti.length} su '
        '${Sentieri.tuttiITraguardi.length}');
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
          'alba',
          'soffio',
          'oracolo',
          'stesa',
          'gettata',
          'tramonto',
          'sogno',
          'sigillo',
          'sinastria',
          'oroscopo',
          'viso',
          'archetipo',
          'presenza',
          'meditazione',
          'chakra',
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
    var sentieriConDormienti = 0;
    for (final s in Sentiero.values) {
      // Si accendono tutti i traguardi fino al primo dormiente del sentiero.
      final voci = Sentieri.di(s).toList()
        ..sort((a, b) => a.posizione.compareTo(b.posizione));
      final primoDormiente = voci.indexWhere((t) => t.dormiente);
      if (primoDormiente < 0) continue;
      sentieriConDormienti++;
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
    // **IL NUMERO SI STAMPA, ordine CP voce 06**: dalla revisione F questa
    // prova gira su zero sentieri, e chi legge il verde deve saperlo.
    // ignore: avoid_print
    print('ORDINE CP VOCE 06: sentieri con almeno un dormiente '
        '$sentieriConDormienti');
  });

  test('la serratura del dormiente tiene ancora, su un dormiente costruito',
      () {
    // **UNA GUARDIA SU UN INSIEME VUOTO NON GUARDA NIENTE.** Ordine CP voce
    // 06: con zero dormienti nel corpus, ogni pretesa che scorra l'elenco e'
    // verde per non aver guardato. Qui il dormiente si COSTRUISCE, e si
    // pretende che la sua condizione risponda falso a qualunque stato: la
    // serratura resta sorvegliata anche il giorno che il corpus non ne ha.
    const dormiente = Dormiente('prova', 'una ragione lunga abbastanza');
    expect(dormiente.chiedeUnAltroGiorno, isTrue);
    var provati = 0;
    for (final stato in [
      const StatoDelCammino(),
      const StatoDelCammino(gestiCompiuti: {'gettata': 99999}),
      const StatoDelCammino(giorniConGesto: {'gettata': 99999}),
      const StatoDelCammino(pezziDellIdentita: {'carta_natale'}),
      const StatoDelCammino(eventiDelCieloDiOggi: {'eclissi'}),
    ]) {
      provati++;
      expect(dormiente.raggiunto(stato), isFalse,
          reason: 'un dormiente si e acceso su uno stato: la prima serratura '
              'non tiene piu');
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 06: stati provati contro un dormiente $provati');
    expect(provati, 5);
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
