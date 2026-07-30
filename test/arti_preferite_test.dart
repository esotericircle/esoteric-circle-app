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

    // IL CASO "PIENO" OGGI NON SI RAGGIUNGE, e va detto invece di far finta di
    // provarlo. Le arti vive sono nove e il tetto e' nove: chi le prende tutte
    // non ha nient'altro da aggiungere. Il rifiuto parlante resta scritto e
    // servira' dal giorno in cui il catalogo crescera'. Questa prova cade quel
    // giorno, e chi la legge sa gia' cosa verificare.
    final fuori = ArtiPreferiteController.selezionabili
        .where((id) => !c.contiene(id))
        .toList();
    expect(fuori, isEmpty,
        reason: 'ci sono ${fuori.length} arti vive fuori da uno scaffale pieno: '
            'il catalogo e\' cresciuto, quindi adesso il rifiuto parlante si '
            'puo\' e si deve provare davvero aggiungendo $fuori');
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
        reason: 'le arti scelte non sono sopravvissute alla chiusura dell\'app');
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
    final righe = File('lib/core/arts/arti_preferite.dart')
        .readAsLinesSync()
        .where((r) {
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
