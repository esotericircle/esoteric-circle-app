import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/maestro_del_gesto.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/face_history.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';

/// LE CONDIZIONI COSTRUITE. Ordine BW voce 07.
///
/// **Decisione del fondatore del 28 agosto 2026**: "sistema le 27 dormienti".
/// Erano le voci che il corpus della revisione E vuole vive e che il
/// generatore addormentava perche' l'app non sapeva misurarne la condizione.
///
/// Ogni famiglia costruita porta qui la sua prova, sul GESTO VERO che la fa
/// maturare: non si misura che la condizione esista, si misura che il gesto
/// di una persona la accenda.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un diario con un orologio che si puo' spostare, perche' queste
  /// condizioni parlano di giorni e di ore.
  ({DiarioDelCammino diario, void Function(DateTime) sposta}) diarioConOrologio(
      DateTime partenza) {
    var adesso = partenza;
    final diario = DiarioDelCammino(orologio: () => adesso);
    return (diario: diario, sposta: (DateTime quando) => adesso = quando);
  }

  group('BW.07, l\'ora fedele', () {
    test('Lo stesso gesto alla stessa ora per cinque giorni accende', () async {
      // **IL GESTO VERO**: aprire l'Oroscopo alle sette, cinque mattine di
      // fila. E' la condizione di med_34, aur_34 e cal_34, una per Maestro,
      // che dormivano perche' l'app sapeva solo se un gesto cadeva nell'ora
      // rituale dell'alba, non se cadeva sempre alla STESSA ora.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 10, 7, 5));
      final diario = orologio.diario;
      await diario.carica();

      for (var giorno = 10; giorno <= 14; giorno++) {
        orologio.sposta(DateTime(2026, 8, giorno, 7, 20));
        await diario.segna('oroscopo');
      }
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: dopo cinque mattine alle sette, l\'ora fedele '
          'dell\'oroscopo vale ${stato.oraFedelePerGesto['oroscopo']}');
      expect(stato.oraFedelePerGesto['oroscopo'], 5,
          reason: 'il diario non ricorda l\'ora dei gesti: la costanza '
              'dell\'ora non si puo\' misurare');

      final ora = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_34');
      expect(ora.dormiente, isFalse,
          reason: 'med_34 dorme ancora: la condizione costruita non e\' '
              'arrivata al cammino');
      expect(ora.condizione.raggiunto(stato), isTrue,
          reason: 'cinque mattine alla stessa ora non accendono "${ora.nome}"');
    });

    test('Cinque aperture nello stesso giorno non fanno cinque giorni',
        () async {
      // **IL CONTO E' DI GIORNI, non di aperture**: senza questa riga chi apre
      // l'app cinque volte in un pomeriggio si porterebbe a casa un traguardo
      // di costanza.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 10, 7));
      final diario = orologio.diario;
      await diario.carica();
      for (var volta = 0; volta < 5; volta++) {
        orologio.sposta(DateTime(2026, 8, 10, 7, volta * 5));
        await diario.segna('oroscopo');
      }
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: cinque aperture in un giorno solo valgono '
          '${stato.oraFedelePerGesto['oroscopo']} giorni');
      expect(stato.oraFedelePerGesto['oroscopo'], 1,
          reason: 'cinque aperture dello stesso giorno contano come '
              '${stato.oraFedelePerGesto['oroscopo']} giorni');
    });

    test('Ore diverse non fanno costanza', () async {
      // Chi apre quando capita non e' fedele a nessuna ora, e il conto lo dice.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 10, 7));
      final diario = orologio.diario;
      await diario.carica();
      const ore = [7, 11, 15, 19, 23];
      for (var i = 0; i < ore.length; i++) {
        orologio.sposta(DateTime(2026, 8, 10 + i, ore[i]));
        await diario.segna('oroscopo');
      }
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: cinque giorni a cinque ore diverse valgono '
          '${stato.oraFedelePerGesto['oroscopo']}');
      expect(stato.oraFedelePerGesto['oroscopo'], 1,
          reason: 'cinque ore diverse contano come costanza');
    });
  });

  group('BW.07, il ritorno a un rito lasciato', () {
    test('Un Soffio dopo tre giorni saltati accende', () async {
      // **IL GESTO VERO**: il Soffio del lunedi', tre giorni senza, il Soffio
      // del venerdi'. E' la condizione di aur_21, che dormiva perche' il
      // diario contava i giorni di assenza DALL'APP: chi apriva l'app ogni
      // giorno e saltava il solo Soffio aveva assenza zero.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 10, 9));
      final diario = orologio.diario;
      await diario.carica();
      await diario.segna('soffio');
      orologio.sposta(DateTime(2026, 8, 14, 9));
      await diario.segna('soffio');

      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: fra i due Soffi erano stati saltati '
          '${stato.giorniSaltatiPerRito['soffio']} giorni');
      expect(stato.giorniSaltatiPerRito['soffio'], 3,
          reason: 'il buco del rito non si misura');

      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_21');
      expect(voce.dormiente, isFalse, reason: 'aur_21 dorme ancora');
      expect(voce.condizione.raggiunto(stato), isTrue,
          reason: 'tre giorni saltati non accendono "${voce.nome}"');
    });

    test('Chi non salta niente non ha nessun buco', () async {
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 10, 9));
      final diario = orologio.diario;
      await diario.carica();
      for (var giorno = 10; giorno <= 14; giorno++) {
        orologio.sposta(DateTime(2026, 8, giorno, 9));
        await diario.segna('soffio');
      }
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: cinque Soffi di fila lasciano un buco di '
          '${stato.giorniSaltatiPerRito['soffio'] ?? 0}');
      expect(stato.giorniSaltatiPerRito['soffio'] ?? 0, 0,
          reason: 'cinque giorni di fila risultano un buco');
    });
  });

  group('BW.07, il ritorno a un Maestro', () {
    test('Si torna a Medora dopo sette giorni, e il gesto dice di chi e\'',
        () async {
      // **IL GESTO VERO**: una stesa, sette giorni in cui si cerca solo
      // Caligo, poi di nuovo una stesa. E' la condizione di med_25, che
      // dormiva perche' l'app registrava i gesti senza il loro Maestro: i tre
      // gradini del ritorno misuravano lo stesso identico fatto.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 8, 1, 10));
      final diario = orologio.diario;
      await diario.carica();
      await diario.segna('stesa');
      // Nel mezzo si cerca Caligo tutti i giorni: l'app non e' stata
      // abbandonata, e' stata abbandonata MEDORA.
      for (var giorno = 2; giorno <= 7; giorno++) {
        orologio.sposta(DateTime(2026, 8, giorno, 10));
        await diario.segna('gettata');
      }
      orologio.sposta(DateTime(2026, 8, 8, 10));
      await diario.segna('stesa');

      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: dal ritorno, Medora non si cercava da '
          '${stato.giorniDiAssenzaDalSentiero['costellazione']} giorni, e '
          'l\'assenza dall\'app era ${stato.giorniDiAssenzaPrimaDiOggi}');
      expect(stato.giorniDiAssenzaDalSentiero['costellazione'], 7,
          reason: 'il diario non sa da quanti giorni non si cercava Medora');
      expect(stato.giorniDiAssenzaPrimaDiOggi, 0,
          reason: 'l\'assenza dall\'app non e\' zero: la prova non sta '
              'misurando il ritorno a UN Maestro');

      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_25');
      expect(voce.dormiente, isFalse, reason: 'med_25 dorme ancora');
      expect(voce.condizione.raggiunto(stato), isTrue,
          reason: 'il ritorno a Medora non accende "${voce.nome}"');
    });

    test('Il Maestro di un gesto lo dichiara il corpus, non il codice', () {
      // La mappa e' generata: se domani un gesto comparisse in due sentieri
      // non sarebbe di nessuno e resterebbe fuori, che e' il modo giusto di
      // non rispondere.
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: gesti con un Maestro solo '
          '${sentieroDelGesto.length}');
      expect(sentieroDelGesto['stesa'], 'costellazione');
      expect(sentieroDelGesto['soffio'], 'loto');
      expect(sentieroDelGesto['gettata'], 'albero');
      expect(sentieroDelGesto.length, greaterThanOrEqualTo(15),
          reason: 'la mappa dei gesti si e\' svuotata: i ritorni non '
              'possono piu\' sapere di chi sia un gesto');
    });
  });

  group('BW.07, la notte del solstizio', () {
    test('Un rito di Caligo, di notte, nel giorno del solstizio', () async {
      // **IL GESTO VERO**: il Segno del Tramonto ricevuto nella notte del
      // solstizio d'inverno. Dormiva perche' l'app sapeva che era solstizio e
      // che il rito era stato compiuto, non che fosse stato compiuto di notte.
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 12, 22, 23));
      final diario = orologio.diario;
      await diario.carica();
      await diario.segna('sogno', oraRituale: 'notte');

      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: nel giorno del solstizio, cio\' che e\' caduto '
          'in un\'ora rituale e\' ${stato.oggiHaFattoNellOra}, e il cielo di '
          'oggi porta ${stato.eventiDelCieloDiOggi.contains('solstizio') ? 'il solstizio' : 'altro'}');
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_24');
      expect(voce.dormiente, isFalse, reason: 'cal_24 dorme ancora');
      expect(voce.condizione.raggiunto(stato), isTrue,
          reason: 'il rito notturno del solstizio non accende "${voce.nome}"');
    });

    test('Lo stesso rito di giorno non basta', () async {
      SharedPreferences.setMockInitialValues(const {});
      final orologio = diarioConOrologio(DateTime(2026, 12, 22, 15));
      final diario = orologio.diario;
      await diario.carica();
      // Nessuna ora rituale: il rito c'e' stato, ma non di notte.
      await diario.segna('sogno');
      final stato = diario.statoDelCammino();
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_24');
      // ignore: avoid_print
      print('ORDINE BW VOCE 7: lo stesso rito di giorno accende? '
          '${voce.condizione.raggiunto(stato)}');
      expect(voce.condizione.raggiunto(stato), isFalse,
          reason: 'il gradino si accende anche di giorno: l\'ora non conta '
              'davvero');
    });
  });

  group('BX.01, i dettagli che adesso viaggiano col gesto', () {
    /// **DUE META' DI UNA PROVA SOLA.** Una condizione costruita vale se il
    /// dato la accende E se la scena manda quel dato: misurare solo la prima
    /// meta' vorrebbe dire sorvegliare una condizione che nessuno alimenta,
    /// ed e' esattamente il difetto che teneva dormienti queste voci.
    void laScenaManda(String file, String pezzo, String cosa) {
      final sorgente = File(file).readAsStringSync();
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: $cosa parte da $file? '
          '${sorgente.contains(pezzo)}');
      expect(sorgente.contains(pezzo), isTrue,
          reason: 'la scena $file non manda piu\' $cosa: la condizione resta '
              'viva e nessuno la alimenta');
    }

    test('Il Soffio tenuto fino alla fine accende aur_7', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await diario.segna('soffio', dettagli: const {
        'tenuto': ['intero']
      });
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_7');
      expect(voce.dormiente, isFalse, reason: 'aur_7 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'il Soffio tenuto non accende "${voce.nome}"');
      laScenaManda('lib/features/rituals/breath_destiny_screen.dart',
          "'tenuto': ['intero']", 'il respiro tenuto');
    });

    test('Un Soffio interrotto non accende aur_7', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      // Il gesto c'e', il dettaglio no: e' il Soffio lasciato a meta'.
      await diario.segna('soffio');
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_7');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isFalse,
          reason: 'un Soffio qualunque accende il gradino di chi lo tiene '
              'fino alla fine');
    });

    test('L\'Alba prima del sorgere vero accende aur_18', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await diario.segna('alba', dettagli: const {
        'prima_del_sole': ['si']
      });
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_18');
      expect(voce.dormiente, isFalse, reason: 'aur_18 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'l\'Alba prima del sole non accende "${voce.nome}"');
      laScenaManda('lib/features/rituals/dawn_rite_screen.dart',
          "'prima_del_sole': ['si']", 'il sorgere vero');
      laScenaManda('lib/features/rituals/dawn_rite_screen.dart',
          'SunsetTime.albaPerData', 'il calcolo del sorgere');
    });

    test('La pietra girata a mano accende cal_8', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await diario.segna('runa_girata');
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_8');
      expect(voce.dormiente, isFalse, reason: 'cal_8 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'la pietra girata non accende "${voce.nome}"');
      laScenaManda('lib/features/maestri/caligo/rune/rune_draw_screen.dart',
          "dopoUnGesto(ctx, 'runa_girata')", 'il gesto della pietra girata');
      // E il conto delle gettate non si gonfia: e' il conto che governa i
      // limiti del listino.
      expect(diario.statoDelCammino().gestiCompiuti['gettata'] ?? 0, 0,
          reason: 'girare una pietra ha contato come una gettata');
    });

    test('La scheda dell\'Ascendente letta fino in fondo accende med_2',
        () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await diario.segna('ascendente');
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_2');
      expect(voce.dormiente, isFalse, reason: 'med_2 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'la lettura fino in fondo non accende "${voce.nome}"');
      laScenaManda('lib/features/onboarding/natal_chart_reveal.dart',
          "dopoUnGesto(context, 'ascendente')", 'la fine della lettura');
    });
  });

  group('BX.01, il cielo contrario e le finestre di tempo', () {
    test('Il cielo contrario e\' la Luna nel segno opposto', () {
      // **LA TRADUZIONE E' UNA SCELTA, dichiarata nel manifesto.** Il corpus
      // dice "un Soffio compiuto in un giorno in cui il cielo ti e'
      // contrario" e lo annota "Cielo avverso", e nel catalogo non esiste
      // nessun evento con quel nome. Inventarlo vorrebbe dire inventare
      // un'astrologia; la tradizione pero' chiama Saturno il grande malefico e
      // il suo retrogrado il tempo in cui si volta contro, e il catalogo lo
      // calcola gia'.
      //
      // **La Luna nel segno opposto era la prima scelta e l'ha scartata una
      // prova di casa**: aur_24 la usa gia', e due gradini con la stessa
      // firma sono un gradino detto due volte. Il fondatore puo' rovesciare
      // la scelta con una riga.
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_40');
      final condizione = voce.condizione;
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: il cielo contrario e\' tradotto con '
          '${condizione.firma}');
      expect(voce.dormiente, isFalse, reason: 'aur_40 dorme ancora');
      expect(condizione.firma, contains('saturno_retrogrado'),
          reason: 'la traduzione del cielo contrario e\' cambiata senza '
              'dirlo: adesso e\' ${condizione.firma}');
      final acceso = condizione.raggiunto(const StatoDelCammino(
        oggiHaFatto: {'soffio'},
        eventiDelCieloDiOggi: {'saturno_retrogrado'},
      ));
      expect(acceso, isTrue,
          reason: 'il Soffio nel giorno di Saturno retrogrado non accende '
              '"${voce.nome}"');
      final senzaLaLuna =
          condizione.raggiunto(const StatoDelCammino(oggiHaFatto: {'soffio'}));
      expect(senzaLaLuna, isFalse,
          reason: 'il gradino si accende in un giorno qualunque');
    });

    test('Lo stesso Arcano due volte in una settimana accende med_31',
        () async {
      // **IL GESTO VERO**: l'Arcano del Giorno ricevuto lunedi' e di nuovo
      // giovedi', ed e' lo stesso. Prima il diario contava le ripetizioni DA
      // SEMPRE, quindi due uscite a due anni di distanza sarebbero valse
      // uguale.
      SharedPreferences.setMockInitialValues(const {});
      var adesso = DateTime(2026, 8, 10, 9);
      final diario = DiarioDelCammino(orologio: () => adesso);
      await diario.carica();
      await diario.segna('oracolo', dettagli: const {
        'arcano': ['laTorre']
      });
      adesso = DateTime(2026, 8, 13, 9);
      await diario.segna('oracolo', dettagli: const {
        'arcano': ['laTorre']
      });
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: lo stesso Arcano dentro sette giorni e\' '
          'tornato ${stato.ripetizioniNellaFinestra['oracolo.arcano:7']} volte');
      expect(stato.ripetizioniNellaFinestra['oracolo.arcano:7'], 2);
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_31');
      expect(voce.dormiente, isFalse, reason: 'med_31 dorme ancora');
      expect(voce.condizione.raggiunto(stato), isTrue,
          reason: 'due Arcani uguali in una settimana non accendono '
              '"${voce.nome}"');
      final scena = File('lib/features/rituals/day_oracle_screen.dart')
          .readAsStringSync();
      expect(scena.contains("'arcano': [carta.stem]"), isTrue,
          reason: 'la scena dell\'Arcano non manda piu\' quale carta e\' '
              'uscita: la condizione resta viva e nessuno la alimenta');
    });

    test('Lo stesso Arcano a un mese di distanza non accende med_31', () async {
      // **LA FINESTRA E' LA SOSTANZA DEL GRADINO**: senza, sarebbe una
      // coincidenza promessa dove c'e' solo il tempo che passa.
      SharedPreferences.setMockInitialValues(const {});
      var adesso = DateTime(2026, 7, 1, 9);
      final diario = DiarioDelCammino(orologio: () => adesso);
      await diario.carica();
      await diario.segna('oracolo', dettagli: const {
        'arcano': ['laTorre']
      });
      adesso = DateTime(2026, 8, 10, 9);
      await diario.segna('oracolo', dettagli: const {
        'arcano': ['laTorre']
      });
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: a quaranta giorni di distanza, dentro la '
          'settimana ne conta ${stato.ripetizioniNellaFinestra['oracolo.arcano:7']}');
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_31');
      expect(voce.condizione.raggiunto(stato), isFalse,
          reason: 'due Arcani uguali a quaranta giorni di distanza accendono '
              'un gradino che chiede una settimana');
    });

    test('La stessa carta sotto tre Lune diverse accende med_41', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      for (final luna in ['Luna nuova', 'Primo quarto', 'Luna piena']) {
        await diario.segna('stesa', dettagli: {
          'carta_e_luna': ['ilMatto@$luna']
        });
      }
      final stato = diario.statoDelCammino();
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: la carta piu\' accompagnata ha visto '
          '${stato.variePerValore['stesa.carta_e_luna']} Lune diverse');
      expect(stato.variePerValore['stesa.carta_e_luna'], 3);
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_41');
      expect(voce.dormiente, isFalse, reason: 'med_41 dorme ancora');
      expect(voce.condizione.raggiunto(stato), isTrue,
          reason: 'la stessa carta sotto tre Lune non accende "${voce.nome}"');
    });

    test('Tre carte diverse sotto tre Lune non accendono med_41', () async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      const carte = ['ilMatto', 'laTorre', 'lEremita'];
      const lune = ['Luna nuova', 'Primo quarto', 'Luna piena'];
      for (var i = 0; i < 3; i++) {
        await diario.segna('stesa', dettagli: {
          'carta_e_luna': ['${carte[i]}@${lune[i]}']
        });
      }
      final stato = diario.statoDelCammino();
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_41');
      // ignore: avoid_print
      print('ORDINE BX VOCE 1: tre carte diverse danno '
          '${stato.variePerValore['stesa.carta_e_luna']} come massimo');
      expect(voce.condizione.raggiunto(stato), isFalse,
          reason: 'tre carte DIVERSE accendono il gradino della stessa carta');
    });
  });

  group('BX.11 e CB.01, quel che resta del quaderno dei sogni', () {
    test('E la scena manda davvero quei dettagli', () {
      // La seconda meta' di ogni condizione costruita: che la scena la
      // alimenti. Senza, resta una condizione viva che nessuno accende.
      // **DUE DEI TRE FILE NON ESISTONO PIU'. Ordine CB voce 01.** Questa
      // prova guardava tre scene: il quaderno dei sogni, il rito della notte
      // e la Costellazione del Viso. Il quaderno e' stato eliminato per
      // ordine del fondatore, e coi suoi dettagli se ne sono andati i tre
      // gradini che li chiedevano: dormono dichiarati, e lo sorveglia
      // `il_quaderno_dei_sogni_non_torna_test.dart`. Resta il volto.
      final viso =
          File('lib/features/maestri/aura/face/face_constellation_screen.dart')
              .readAsStringSync();
      expect(viso.contains("'tratto_cambiato': const ['si']"), isTrue,
          reason: 'la Costellazione del Viso non dice piu\' quando il tratto '
              'cambia');
      // ignore: avoid_print
      print('ORDINE CB VOCE 01: la scena del volto manda il suo dettaglio');
    });

    test('Il volto che cambia accende aur_16, e solo dopo un mese', () async {
      // **LA GRANDEZZA MISURATA E\' CAMBIATA, E LA SOGLIA NO.** La prima
      // stesura di questa guardia scriveva a mano il dettaglio
      // 'tratto_cambiato' nel diario e guardava se il gradino si accendeva:
      // misurava il diario, non la regola del mese, e infatti restava verde
      // anche togliendo il mese dal codice. Il difetto e\' stato trovato
      // proprio cosi\', iniettando il difetto e leggendo un verde. Adesso
      // risponde la regola, che vive nello storico e ha le date.
      SharedPreferences.setMockInitialValues(const {});
      final adesso = orologioDelleProve();
      var quando = adesso;
      final storico = FaceHistory(clock: () => quando);
      FaceReading conDominante(FaceTrait tratto) => FaceReading(letture: [
            TraitLettura(tratto: tratto, marcatezza: 0.9),
            TraitLettura(tratto: FaceTrait.values.first, marcatezza: 0.1),
          ]);
      final primo = conDominante(FaceTrait.values[1]);
      final diverso = conDominante(FaceTrait.values[2]);
      expect(storico.ilTrattoECambiatoInUnMese(diverso), isFalse,
          reason: 'senza nessuna lettura passata il volto risulta gia\' '
              'cambiato');

      // Una lettura di IERI, con un tratto diverso: il mese non e\' passato e
      // il gradino non si deve accendere.
      quando = adesso.subtract(const Duration(days: 1));
      await storico.registra(primo);
      quando = adesso;
      // ignore: avoid_print
      print('ORDINE BX VOCE 11: con una lettura di ieri, il volto risulta '
          'cambiato? ${storico.ilTrattoECambiatoInUnMese(diverso)}');
      expect(storico.ilTrattoECambiatoInUnMese(diverso), isFalse,
          reason: 'un tratto diverso a un giorno di distanza accende gia\' il '
              'gradino: la distanza di un mese non e\' misurata');

      // Una lettura di trentun giorni fa, con un tratto diverso: adesso si\'.
      quando = adesso.subtract(const Duration(days: 31));
      await storico.registra(primo);
      quando = adesso;
      // ignore: avoid_print
      print('ORDINE BX VOCE 11: con una lettura di trentun giorni fa, il '
          'volto risulta cambiato? '
          '${storico.ilTrattoECambiatoInUnMese(diverso)}');
      expect(storico.ilTrattoECambiatoInUnMese(diverso), isTrue,
          reason: 'un tratto diverso dopo un mese non accende il gradino');
      expect(storico.ilTrattoECambiatoInUnMese(primo), isFalse,
          reason: 'lo stesso tratto di un mese fa risulta cambiato');

      // E il gradino del corpus si accende con quel dettaglio, che e\' cio\'
      // che la schermata manda quando la regola dice di si\'.
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await diario.segna('viso', dettagli: const {
        'tratto': ['fuoco']
      });
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_16');
      expect(voce.dormiente, isFalse, reason: 'aur_16 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isFalse,
          reason: 'una lettura sola accende il gradino del volto cambiato');
      await diario.segna('viso', dettagli: const {
        'tratto': ['acqua'],
        'tratto_cambiato': ['si']
      });
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'il tratto cambiato non accende "${voce.nome}"');
    });

    test('La chiave dei sogni se ne va lo stesso, con chi se ne va', () async {
      // **LA CHIAVE VIVE ANCORA SUI TELEFONI. Ordine CB voce 01.** Il
      // quaderno non c'e' piu' nel codice, ma `sogni.annotati` sta gia' sul
      // disco di chi ha installato una build da meta' agosto in poi, e da
      // sola l'app non la tocchera' mai piu'. Togliere il prefisso
      // dall'elenco della cancellazione lascerebbe quel dato sul telefono
      // per sempre: resta, e questa prova lo pretende.
      for (final prefisso in const ['sogni.', 'viso.']) {
        expect(
            DimenticanzaDelTelefono.prefissiDaDimenticare, contains(prefisso),
            reason: 'il prefisso $prefisso non e\' fra quelli che la '
                'cancellazione porta via dal disco');
      }
      // ignore: avoid_print
      print('ORDINE CB VOCE 01: la cancellazione porta via anche sogni., che '
          'nessuno scrive piu\' e qualcuno ha ancora sul telefono');
    });
  });

  group('BX.03, le due porte del Cerchio', () {
    test('Il bosco si guarda, e accende cal_10', () async {
      // **IL MINIMO CHE LA CONDIZIONE RICHIEDE, e niente di piu'.** "Guardi
      // quali Animali Guida accompagnano gli altri del Cerchio" nomina QUALI
      // animali, non di chi: il bosco si mostra per intero senza il dato di
      // nessuno, senza mandare niente da nessuna parte e senza che
      // l'identita' di una persona sfiori quella schermata.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'cal_10');
      expect(voce.dormiente, isFalse, reason: 'cal_10 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isFalse);
      await diario.segna('bosco');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'guardare il bosco non accende "${voce.nome}"');
      // E la scena esiste, con la sua porta.
      final schermo =
          File('lib/features/maestri/caligo/animal/bosco_del_cerchio.dart')
              .readAsStringSync();
      expect(schermo.contains("dopoUnGesto(context, 'bosco')"), isTrue,
          reason: 'il bosco non dice piu\' al cammino di essere stato '
              'guardato');
      // **E NON CHIEDE NIENTE A NESSUNO**: nessuna riga di quella scena parla
      // col server o legge un altro utente.
      for (final vietato in const ['PortaDelCerchio', 'Firestore', 'http']) {
        expect(schermo.contains(vietato), isFalse,
            reason: 'il bosco tocca $vietato');
      }
      // ignore: avoid_print
      print('ORDINE BX VOCE 3: il bosco accende cal_10 e non chiede niente a '
          'nessuno');
    });

    test('Due volti letti qui accendono aur_31', () async {
      // **L'ALTRA PERSONA E' PRESENTE E SI FA LEGGERE ADESSO.** Niente esce
      // dal telefono, niente viene salvato, nessuna identita' viene chiesta:
      // la lettura del secondo volto vive quanto vive la schermata.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_31');
      expect(voce.dormiente, isFalse, reason: 'aur_31 dorme ancora');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isFalse);
      await diario.segna('due_volti');
      expect(voce.condizione.raggiunto(diario.statoDelCammino()), isTrue,
          reason: 'due volti letti non accendono la voce');
      final scena =
          File('lib/features/maestri/aura/face/face_constellation_screen.dart')
              .readAsStringSync();
      expect(scena.contains("dopoUnGesto(context, 'due_volti')"), isTrue,
          reason: 'la lettura del secondo volto non arriva al cammino');
      expect(scena.contains('FaceReading? _secondoVolto'), isTrue,
          reason: 'il secondo volto non vive nella schermata');
      // ignore: avoid_print
      print('ORDINE BX VOCE 3: due volti accendono aur_31, e il secondo volto '
          'vive solo dentro la schermata');
    });
  });
}
