import 'dart:io';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/ritual_streak.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un servizio finto, che registra cosa gli e' stato chiesto senza toccare
/// nessuna piattaforma.
class _AvvisiFinti extends ServizioAvvisi {
  _AvvisiFinti({this.permesso = true});

  bool permesso;

  @override
  bool get disponibile => true;

  final Map<int, ({DateTime quando, String titolo, String testo})> programmati =
      {};
  int annullamenti = 0;
  int richiestePermesso = 0;

  @override
  Future<bool> chiediPermesso() async {
    richiestePermesso++;
    return permesso;
  }

  @override
  Future<bool> permessoConcesso() async => permesso;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmati[id] = (quando: quando, titolo: titolo, testo: testo);
  }

  @override
  Future<void> annulla(int id) async {
    annullamenti++;
    programmati.remove(id);
  }

  @override
  Future<List<int>> inAttesa() async => programmati.keys.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lat = 45.4642;
  const lon = 9.1900;
  const fuso = Duration(hours: 2);

  PosizioneDiStamattina conPosizione() => PosizioneDiStamattina.da(
      const SkyPlace(latitude: lat, longitude: lon), fuso);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Chi rifiuta il permesso non perde niente', () {
    test('senza permesso non si programma nulla', () async {
      final servizio = _AvvisiFinti(permesso: false);
      final esito = await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: DateTime(2026, 8, 6, 3),
        posizione: conPosizione(),
      );
      expect(esito, EsitoAvviso.senzaPermesso);
      expect(servizio.programmati, isEmpty);
    });

    test('IL RITO RESTA INTERO per chi ha detto no', () async {
      // E' la prova che conta: rifiutare il permesso non deve togliere niente.
      // Il rito si compone identico, con gli stessi tre momenti e la stessa
      // via col dito, che il permesso ci sia o no.
      final giorno = DateTime(2026, 8, 6);
      final posizione = conPosizione();

      final servizioSi = _AvvisiFinti(permesso: true);
      final servizioNo = _AvvisiFinti(permesso: false);
      await AvvisiDelRito.programmaProssimo(
          servizio: servizioSi, adesso: giorno, posizione: posizione);
      await AvvisiDelRito.programmaProssimo(
          servizio: servizioNo, adesso: giorno, posizione: posizione);

      final rito = RitoAlba.diOggi(giorno, posizione: posizione);
      expect(rito, isNotNull);
      expect(rito!.gesto, isNotEmpty);
      expect(rito.respiro, isNotEmpty);
      expect(rito.parola, isNotEmpty);
      expect(rito.viaTattile, isNotEmpty);
      expect(rito.datiNominati, isNotEmpty);

      // E la fascia del risveglio si dichiara lo stesso: dipende dalla
      // posizione, non dal permesso di notifica.
      final fascia = FasciaDelRisveglio.per(giorno, posizione: posizione);
      expect(fascia.dichiarabile, isTrue);
      expect(RitoAlba.avvisoDellaFascia(fascia), hasLength(3));

      // L'unica differenza e' l'avviso.
      expect(servizioSi.programmati, isNotEmpty);
      expect(servizioNo.programmati, isEmpty);
    });

    test('senza servizio disponibile non si rompe niente', () async {
      const spenti = AvvisiSpenti();
      expect(spenti.disponibile, isFalse);
      expect(await spenti.chiediPermesso(), isFalse);
      expect(await spenti.inAttesa(), isEmpty);
      expect(
        await AvvisiDelRito.programmaProssimo(
            servizio: spenti, adesso: DateTime(2026, 8, 6)),
        EsitoAvviso.senzaPermesso,
      );
    });
  });

  group('L\'avviso non parte se il rito e\' gia\' stato aperto', () {
    test('aperto oggi: l\'avviso salta a domani', () async {
      final adesso = DateTime(2026, 8, 6, 9);
      // Il rito viene compiuto adesso, come fa la schermata.
      await const RitualStreak().recordToday(adesso);
      expect(await const RitualStreak().fattoOggi(adesso), isTrue);

      final servizio = _AvvisiFinti();
      final esito = await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: adesso,
        posizione: conPosizione(),
      );

      expect(esito, EsitoAvviso.ritoGiaAperto,
          reason: 'avvisare di fare una cosa gia\' fatta e\' rumore');
      final quando = servizio.programmati[AvvisiDelRito.idAvvisoAlba]!.quando;
      expect(quando.day, 7,
          reason: 'l\'avviso doveva scivolare al giorno dopo, invece cade il '
              'giorno gia\' compiuto');
    });

    test('non aperto oggi: l\'avviso e\' per il risveglio piu\' vicino',
        () async {
      // Le tre di notte: l'alba di oggi deve ancora arrivare.
      final adesso = DateTime(2026, 8, 6, 3);
      expect(await const RitualStreak().fattoOggi(adesso), isFalse);

      final servizio = _AvvisiFinti();
      final esito = await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: adesso,
        posizione: conPosizione(),
      );
      expect(esito, EsitoAvviso.programmatoSullAlbaVera);
      final quando = servizio.programmati[AvvisiDelRito.idAvvisoAlba]!.quando;
      expect(quando.day, 6);
      expect(quando.isAfter(adesso), isTrue);
    });

    test('non aperto ma l\'alba e\' passata: si va a domani', () async {
      final adesso = DateTime(2026, 8, 6, 20);
      final servizio = _AvvisiFinti();
      await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: adesso,
        posizione: conPosizione(),
      );
      final quando = servizio.programmati[AvvisiDelRito.idAvvisoAlba]!.quando;
      expect(quando.day, 7,
          reason: 'l\'avviso e\' stato programmato per un\'ora gia\' passata');
    });

    test('riprogrammare non affianca, sostituisce', () async {
      final servizio = _AvvisiFinti();
      for (var i = 0; i < 5; i++) {
        await AvvisiDelRito.programmaProssimo(
          servizio: servizio,
          adesso: DateTime(2026, 8, 6, 3),
          posizione: conPosizione(),
        );
      }
      expect(await servizio.inAttesa(), hasLength(1),
          reason: 'cinque programmazioni hanno lasciato piu\' di un avviso');
      expect(servizio.annullamenti, 5,
          reason: 'non si annulla il precedente prima di riprogrammare');
    });
  });

  group('Una porta sola programma avvisi', () {
    test('nessun altro punto in lib programma un avviso', () {
      // Se qualcuno programmasse da un secondo punto, l'avviso si sdoppierebbe
      // oppure uno dei due annullerebbe l'altro senza saperlo.
      const laPorta = 'lib/core/rituals/avvisi_del_rito.dart';
      const ilTrasporto = 'lib/services/avvisi_locali.dart';

      final colpevoli = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = f.path.replaceAll(r'\', '/');
        final relativo = percorso.substring(percorso.indexOf('lib/'));
        if (relativo == laPorta || relativo == ilTrasporto) continue;
        final testo = f.readAsStringSync();
        for (final spia in ['zonedSchedule', 'FlutterLocalNotificationsPlugin']) {
          if (testo.contains(spia)) colpevoli.add('$relativo: $spia');
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'un secondo punto programma avvisi: $colpevoli');
    });

    test('il trasporto vero e\' l\'unico che conosce il plugin', () {
      final trasporto =
          File('lib/services/avvisi_locali.dart').readAsStringSync();
      expect(trasporto, contains('zonedSchedule'));
      // E la porta delle regole non conosce il plugin: se lo conoscesse, le
      // regole non si potrebbero provare senza la piattaforma.
      final porta =
          File('lib/core/rituals/avvisi_del_rito.dart').readAsStringSync();
      expect(porta.contains('flutter_local_notifications'), isFalse,
          reason: 'le regole si sono legate al plugin');
    });

    test('un id solo per l\'avviso dell\'alba', () async {
      final servizio = _AvvisiFinti();
      await AvvisiDelRito.programmaProssimo(
          servizio: servizio,
          adesso: DateTime(2026, 8, 6, 3),
          posizione: conPosizione());
      expect(await servizio.inAttesa(), [AvvisiDelRito.idAvvisoAlba]);
    });
  });

  group('L\'ora e\' vera quando si puo\', media quando no', () {
    test('senza posizione si usa l\'ora media e non si dichiara un\'ora', () async {
      final servizio = _AvvisiFinti();
      final esito = await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: DateTime(2026, 8, 6, 3),
        posizione: PosizioneDiStamattina.da(null, fuso),
      );
      expect(esito, EsitoAvviso.programmatoSullOraMedia);
      final quando = servizio.programmati[AvvisiDelRito.idAvvisoAlba]!.quando;
      expect(quando.hour, 6, reason: 'l\'ora media dell\'alba e\' le sei');
      expect(quando.minute, 0);
    });

    test('nei casi polari si ripiega sull\'ora media invece di tacere',
        () async {
      final servizio = _AvvisiFinti();
      final esito = await AvvisiDelRito.programmaProssimo(
        servizio: servizio,
        adesso: DateTime(2026, 6, 21, 1),
        posizione: PosizioneDiStamattina.da(
            const SkyPlace(latitude: 69.6492, longitude: 18.9553), fuso),
      );
      expect(esito, EsitoAvviso.programmatoSullOraMedia);
      expect(servizio.programmati, isNotEmpty);
    });
  });

  group('Il testo non promette e non anticipa', () {
    test('non nomina il Maestro ne il contenuto del dono', () {
      const tutto = '${AvvisiDelRito.titolo} ${AvvisiDelRito.testo}';
      for (final parola in ['Medora', 'Aura', 'Caligo', 'gesto', 'respiro']) {
        expect(tutto.toLowerCase().contains(parola.toLowerCase()), isFalse,
            reason: 'l\'avviso anticipa il dono nominando "$parola"');
      }
    });

    test('non promette esiti', () {
      const tutto = '${AvvisiDelRito.titolo} ${AvvisiDelRito.testo} '
          '${AvvisiDelRito.spiegazione}';
      for (final v in [
        'guarigione', 'salute', 'fortuna', 'successo', 'garantito', 'protegge',
        'ti sentirai',
      ]) {
        expect(tutto.toLowerCase().contains(v), isFalse,
            reason: 'l\'avviso promette un esito con "$v"');
      }
    });

    test('la spiegazione dichiara che l\'ora e\' approssimata', () {
      final s = AvvisiDelRito.spiegazione.toLowerCase();
      expect(s.contains('indicativo') || s.contains('finestra'), isTrue,
          reason: 'la spiegazione non dice che l\'ora non e\' al minuto, e su '
              'Android 14 non possiamo prometterla');
      // **LA RADICE E NON LA FORMA.** Ordine BC voce 05: i riti che restano
      // interi a chi rifiuta adesso sono cinque, quindi la frase e' passata
      // dal singolare al plurale. La pretesa vera e' che quella promessa ci
      // sia, non come sia coniugata: cercare "resta intero" faceva cadere la
      // prova su una frase scritta bene, ed e' lo stesso inciampo gia' visto
      // nell'ordine BB voce 02 con i plurali del borsellino.
      expect(s.contains('resta inter') || s.contains('restano inter'), isTrue,
          reason: 'la spiegazione non dice che chi rifiuta non perde niente');
    });

    test('il manifest non chiede permessi di sveglia', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('POST_NOTIFICATIONS'));
      for (final vietato in ['SCHEDULE_EXACT_ALARM', 'USE_EXACT_ALARM']) {
        expect(RegExp('uses-permission[^>]*$vietato').hasMatch(manifest), isFalse,
            reason: 'dichiarare $vietato ci espone al rifiuto di Google Play: '
                'non siamo ne una sveglia ne un calendario');
      }
    });
  });
}
