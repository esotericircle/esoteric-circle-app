import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/maestro_del_gesto.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      expect(voce.dormiente, isFalse,
          reason: 'aur_21 dorme ancora');
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
}
