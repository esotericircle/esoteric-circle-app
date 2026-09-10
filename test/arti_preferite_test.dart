import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lo scaffale personale "Le tue arti": le tre regole vivono nel dato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Non parte mai vuoto, nemmeno al primo avvio', () async {
    for (final m in Maestro.values) {
      final c = ArtiPreferiteController(maestroAssegnato: m);
      await c.carica();
      expect(c.ids, isNotEmpty,
          reason: 'con ${m.displayName} assegnato lo scaffale nasce vuoto, '
              'cioe\' una stanza spoglia con scritto "personalizzami"');
    }
  });

  test('Non parte vuoto nemmeno senza Maestro assegnato', () async {
    final c = ArtiPreferiteController();
    await c.carica();
    expect(c.ids, isNotEmpty);
    expect(c.ids.length, greaterThanOrEqualTo(3),
        reason: 'prima della Risonanza lo scaffale deve comunque essere '
            'abitato');
  });

  test('Il seme parte dal proprio Maestro senza chiudersi in un dominio',
      () async {
    final c = ArtiPreferiteController(maestroAssegnato: Maestro.caligo);
    await c.carica();
    final diCaligo = ArtCatalog.activeOf(Maestro.caligo).map((a) => a.id);
    expect(c.ids.where(diCaligo.contains).length, greaterThanOrEqualTo(2),
        reason: 'il seme non pesca dal Maestro assegnato');
    final altri = c.ids.where((id) => !diCaligo.contains(id));
    expect(altri, isNotEmpty,
        reason: 'lo scaffale nasce monocolore: la persona resta chiusa nel suo '
            'dominio senza sapere che gli altri esistono');
  });

  test('Svuotandolo torna il seme, mai il vuoto', () async {
    final c = ArtiPreferiteController(maestroAssegnato: Maestro.aura);
    await c.carica();
    final iniziali = [...c.ids];

    EsitoPreferita? ultimo;
    for (final id in iniziali) {
      ultimo = c.cambia(id);
    }

    expect(ultimo, EsitoPreferita.ripristinata,
        reason: 'togliere l\'ultima arte non ha ripristinato lo scaffale');
    expect(c.ids, isNotEmpty, reason: 'lo scaffale e\' rimasto vuoto');
    expect(c.ids, iniziali,
        reason: 'il ripristino non ha riportato il seme del proprio Maestro');
  });

  test('Il tetto e\' nove, e oltre lo dice invece di ignorare', () async {
    final c = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await c.carica();
    // Si riempie fino al tetto.
    for (final id in ArtiPreferiteController.selezionabili) {
      if (!c.contiene(id)) c.cambia(id);
    }
    expect(c.ids.length, ArtiPreferiteController.tetto);
    // Nove dal 30 luglio 2026, era sei: e' un cambio di decisione del
    // fondatore, non una svista. Il numero resta in un punto solo.
    expect(c.ids.length, 9);

    // **IL CASO DEL RIFIUTO SI PROVA SOLTANTO QUANDO ESISTE, e quando non
    // esiste si dice perche'.** Tre stati diversi di questa stessa prova, e
    // vale la pena tenerli tutti e tre scritti.
    //
    // Fino all'ordine CS le arti vive erano nove e il tetto nove: il caso
    // «pieno» non si raggiungeva, e qui c'era una riga che lo dichiarava
    // invece di fingere di provarlo. Con l'Angelo Custode vivo sono diventate
    // dieci e **il rifiuto si e' potuto provare davvero**.
    //
    // Con l'ordine DC sono tornate nove: la voce 17 ha tolto l'Angelo dalle
    // arti per lasciarlo nel solo Passaporto, la voce 18 ha fuso le due voci
    // di Caligo in una. **Il caso del rifiuto e' di nuovo irraggiungibile**, e
    // fingere di provarlo sarebbe la cosa peggiore delle tre.
    //
    // Quindi: se una decima arte c'e', il rifiuto si prova; se non c'e', si
    // prova **la legge che lo rende irraggiungibile**, cioe' che il catalogo
    // non supera il tetto. La riga cade da sola il giorno in cui una delle due
    // cose cambia, e chi la legge sa gia' cosa verificare.
    final fuori = ArtiPreferiteController.selezionabili
        .where((id) => !c.contiene(id))
        .toList();
    if (fuori.isEmpty) {
      // ignore: avoid_print
      print('ORDINE DC VOCE 18: arti selezionabili '
          '${ArtiPreferiteController.selezionabili.length}, tetto '
          '${ArtiPreferiteController.tetto}: il rifiuto parlante non si puo '
          'raggiungere, e questa prova lo dichiara invece di fingerlo');
      expect(ArtiPreferiteController.selezionabili.length,
          lessThanOrEqualTo(ArtiPreferiteController.tetto),
          reason: 'esiste un arte fuori dallo scaffale pieno e questa prova '
              'non la sta usando: il ramo del rifiuto va riacceso');
      return;
    }
    final esito = c.cambia(fuori.first);
    expect(esito, EsitoPreferita.pieno,
        reason: 'a scaffale pieno l\'arte in piu\' entra lo stesso, e il '
            'tetto non e\' un tetto');
    expect(c.ids.length, ArtiPreferiteController.tetto,
        reason: 'il rifiuto ha comunque cambiato lo scaffale');
    expect(c.contiene(fuori.first), isFalse,
        reason: 'l\'arte rifiutata risulta dentro lo scaffale');
  });

  test('Le scelte sopravvivono al riavvio', () async {
    final primo = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await primo.carica();
    final tolta = primo.ids.first;
    primo.cambia(tolta);
    final atteso = [...primo.ids];

    // Nuovo avvio dell'app: stesso disco, controller nuovo.
    final secondo = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await secondo.carica();
    expect(secondo.ids, atteso,
        reason:
            'le arti scelte non sono sopravvissute alla chiusura dell\'app');
    expect(secondo.contiene(tolta), isFalse,
        reason: 'l\'arte togliata e\' ricomparsa al riavvio');
  });

  test('Un\'arte ritirata dal catalogo non lascia una tessera morta', () async {
    SharedPreferences.setMockInitialValues({
      'arti_preferite_v1': ['horoscope', 'arte_che_non_esiste_piu'],
    });
    final c = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await c.carica();
    expect(c.contiene('arte_che_non_esiste_piu'), isFalse);
    expect(c.contiene('horoscope'), isTrue);
  });

  test('Comprende le arti che l\'elenco del Santuario non mostrava', () {
    // L'Estrazione Rune e il Sigillo dell'Intenzione sono arti vive che nello
    // scaffale del Santuario non c'erano: dal Santuario non si raggiungevano.
    expect(ArtiPreferiteController.selezionabili, contains('rune_draw'));
    expect(ArtiPreferiteController.selezionabili, contains('magic_sigil'));
  });

  test('Nessun piano a pagamento tocca i preferiti', () {
    // L'ordine chiede espressamente che i preferiti restino fuori dai piani.
    // Si legge il file, ma solo il CODICE: i commenti nominano quelle parole
    // proprio per spiegare che non si usano, e cercarle anche li' farebbe
    // fallire il test per la ragione opposta a quella che deve misurare.
    final righe =
        File('lib/core/arts/arti_preferite.dart').readAsLinesSync().where((r) {
      final t = r.trimLeft();
      return !t.startsWith('//') && !t.startsWith('///');
    });
    final s = righe.join('\n');
    for (final parola in const [
      'Tier',
      'tier',
      'Entitlement',
      'entitlement',
      'premium',
      'Premium',
      'abbonamento',
      'PlanCatalog',
    ]) {
      expect(s.contains(parola), isFalse,
          reason: 'i preferiti leggono "$parola": una comodita\' di chi usa '
              'l\'app e\' diventata merce');
    }
  });
}
