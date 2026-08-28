import 'dart:async';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:esoteric_circle/core/permissions/esito_del_permesso.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/chiamata_del_primo_giorno.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/services/regia_delle_chiamate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE NOTIFICHE ARRIVANO DAVVERO. Ordine BZ voce 04.
///
/// **Parole del fondatore:** "LE NOTIFICHE NON FUNZIONANO! Stamattina e oggi
/// me ne sarebbero dovute arrivare 3 invece nemmeno una."
///
/// **LA GRANDEZZA MISURATA E' QUANTE CHIAMATE IL SISTEMA DEL TELEFONO HA
/// DAVVERO IN CODA DOPO UN AVVIO**, e non quante l'app crede di aver chiesto.
/// E' la distinzione che l'ordine chiede per nome, ed e' anche la ragione per
/// cui il difetto e' vissuto per settimane sotto una suite verde: ogni prova
/// degli avvisi costruisce il servizio finto con `permesso = true`, cioe'
/// misura la catena a permesso gia' concesso. Ogni misura era vera e la
/// conclusione falsa: la catena funziona, e non parte mai.
///
/// **Il telefono finto di questa prova parte come un telefono vero**: nessun
/// permesso concesso, e il permesso si concede solo se qualcuno lo CHIEDE al
/// sistema. Conta anche quante volte glielo si e' chiesto.
class _TelefonoFinto extends ServizioAvvisi {
  _TelefonoFinto({this.rispondeSi = true});

  /// Cosa risponde la persona quando il sistema chiede.
  bool rispondeSi;

  /// Quello che il sistema ha davvero in coda.
  final Map<int, DateTime> coda = {};

  /// Quante volte l'app ha chiesto il permesso al sistema.
  int volteChiesto = 0;

  bool _concesso = false;

  @override
  bool get disponibile => true;

  @override
  Future<bool> chiediPermesso() async {
    volteChiesto++;
    // Come un telefono vero: il dialogo compare, e se la persona accetta il
    // permesso resta concesso da li' in avanti.
    if (rispondeSi) _concesso = true;
    return _concesso;
  }

  @override
  Future<bool> permessoConcesso() async => _concesso;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    coda[id] = quando;
  }

  @override
  Future<void> annulla(int id) async => coda.remove(id);

  @override
  Future<List<int>> inAttesa() async => coda.keys.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  /// L'AVVIO DELL'APP, negli stessi due passi e nello stesso ordine di
  /// `lib/app.dart`: prima la porta che puo' chiedere il permesso, poi la
  /// regia che programma. Non si monta l'app intera perche' porterebbe dentro
  /// rete, Firebase e mezzo albero: cio' che questa voce misura sono i due
  /// passi dell'avvio e cosa resta in coda al telefono dopo.
  Future<int> unAvvio(
    WidgetTester tester,
    _TelefonoFinto telefono, {
    required bool dentroIlCerchio,
    bool accetta = true,
  }) async {
    // **LA FINESTRA E' QUELLA DI UN TELEFONO, non gli 800x600 di serie.**
    // Il foglio della spiegazione porta sette righe di testo: su una finestra
    // alta 600 il bottone "Sì, avvisami" finisce sotto il bordo, il tocco non lo
    // colpisce, il foglio non si chiude e la prova aspetta un futuro che non
    // arrivera' mai. E' lo stesso difetto di misura del Santuario.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late BuildContext preso;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SceltaDegliAvvisi()),
      ],
      child: MaterialApp(
        home: Builder(builder: (context) {
          preso = context;
          return const Scaffold(body: SizedBox.shrink());
        }),
      ),
    ));
    await tester.pump();
    // **NON SI ASPETTA UN FUTURO SENZA PIU' DISEGNARE.** In una prova di
    // widget il tempo lo fa avanzare `pump`: mettersi in `await` su un futuro
    // che dipende dal foglio vuol dire fermare i fotogrammi proprio mentre il
    // foglio aspetta una risposta, e la prova resta appesa per sempre (il
    // foglio non si chiude da solo: isDismissible e' falso). Misurato: "did
    // not complete" dopo tre minuti. Si segna quando il futuro finisce e si
    // continua a disegnare finche' non finisce.
    // **LA RISPOSTA DELLA PERSONA SI INIETTA.** Il foglio vero e' un
    // `showModalBottomSheet` che non si chiude da solo: aspettarne il futuro
    // in una prova vuol dire smettere di disegnare mentre lui aspetta, e la
    // prova resta appesa. Qui si misura cosa resta in coda al telefono.
    ChiamataDelPrimoGiorno.spiegazionePerLeProve = (_) async => accetta;
    addTearDown(() => ChiamataDelPrimoGiorno.spiegazionePerLeProve = null);
    var chiesto = false;
    unawaited(ChiamataDelPrimoGiorno.forseChiedi(preso,
            servizio: telefono, dentroIlCerchio: dentroIlCerchio)
        .then((_) => chiesto = true));
    for (var i = 0; i < 30 && !chiesto; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(chiesto, isTrue,
        reason: 'la porta del permesso non ha mai finito: la prova starebbe '
            'misurando una scena a meta\'');
    var programmato = false;
    unawaited(RegiaDelleChiamate.riprogramma(preso, servizio: telefono)
        .then((_) => programmato = true));
    for (var i = 0; i < 30 && !programmato; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(programmato, isTrue,
        reason: 'la regia delle chiamate non ha mai finito');
    return telefono.coda.length;
  }

  testWidgets(
      'Dopo un avvio, su un telefono che non ha mai concesso niente, il '
      'sistema ha le cinque chiamate in coda', (tester) async {
    final telefono = _TelefonoFinto();
    final quante = await unAvvio(tester, telefono, dentroIlCerchio: true);
    // ignore: avoid_print
    print('ORDINE BZ VOCE 4: dopo un avvio il sistema ha $quante chiamate in '
        'coda, e il permesso e\' stato chiesto ${telefono.volteChiesto} volte');
    expect(telefono.volteChiesto, 1,
        reason: 'l\'app non ha chiesto il permesso nemmeno una volta: da '
            'Android 13 le notifiche nascono negate, quindi non ne arrivera\' '
            'nessuna e nessuno sapra\' perche\'');
    expect(quante, DailyElement.values.length,
        reason: 'il sistema del telefono ha $quante chiamate in coda invece di '
            '${DailyElement.values.length}: e\' il numero che arriva davvero, '
            'non quello che l\'app crede di aver chiesto');
  });

  testWidgets('Chi dice di no non riceve niente, e non gli si chiede piu\'',
      (tester) async {
    final telefono = _TelefonoFinto(rispondeSi: false);
    final quante =
        await unAvvio(tester, telefono, dentroIlCerchio: true, accetta: false);
    expect(quante, 0,
        reason: 'senza permesso il sistema ha $quante chiamate in coda: '
            'qualcuno le ha programmate contro la volonta\' della persona');
    // Un secondo avvio: la spiegazione non torna.
    final ancora = await unAvvio(tester, telefono, dentroIlCerchio: true);
    // ignore: avoid_print
    print('ORDINE BZ VOCE 4: dopo un no, al secondo avvio il permesso e\' '
        'stato chiesto ${telefono.volteChiesto} volte in tutto');
    expect(ancora, 0);
    expect(telefono.volteChiesto, lessThanOrEqualTo(1),
        reason: 'la spiegazione torna a ogni avvio: su Android il dialogo di '
            'sistema compare una volta sola e insistere non aggiunge una '
            'possibilita\', la toglie');
  });

  testWidgets('A chi sta entrando nel Cerchio non si chiede niente',
      (tester) async {
    final telefono = _TelefonoFinto();
    final quante = await unAvvio(tester, telefono, dentroIlCerchio: false);
    expect(telefono.volteChiesto, 0,
        reason: 'il permesso viene chiesto sopra il Risveglio, che e\' la '
            'prima impressione dell\'app');
    expect(quante, 0);
  });

  testWidgets('Chi il permesso ce l\'ha gia\' non vede nessun foglio',
      (tester) async {
    final telefono = _TelefonoFinto();
    // Come un telefono su cui il Rito dell'Alba aveva gia' chiesto.
    await telefono.chiediPermesso();
    telefono.volteChiesto = 0;
    final quante = await unAvvio(tester, telefono, dentroIlCerchio: true);
    expect(telefono.volteChiesto, 0,
        reason: 'a chi ha gia\' concesso il permesso si richiede lo stesso');
    expect(quante, DailyElement.values.length);
  });

  test('La memoria di questa porta e\' sua, e se ne va con la persona',
      () async {
    // La chiave nuova non deve sfuggire alla cancellazione: e' una memoria
    // della persona come tutte le altre, e la prova della voce BZ.01 la
    // troverebbe da sola, ma qui si dice anche perche' comincia per `avvisi.`.
    expect(ChiamataDelPrimoGiorno.chiaveChiesto, startsWith('avvisi.'),
        reason: 'la chiave non ha un prefisso che la cancellazione dimentica');
    SharedPreferences.setMockInitialValues(const {});
    expect(await ChiamataDelPrimoGiorno.giaChiesto(), isFalse);
    await ChiamataDelPrimoGiorno.segnaChiesto();
    expect(await ChiamataDelPrimoGiorno.giaChiesto(), isTrue);
  });

  test('La spiegazione che si mostra e\' quella dei cinque Doni', () {
    // Non si riscrive una seconda spiegazione: e' la stessa del Rito
    // dell'Alba e del menu' Notifiche, che nomina i cinque Doni e le ore.
    expect(AvvisiDelRito.spiegazione, contains('cinque avvisi al giorno'));
    for (final parola in const ['Alba', 'Soffio', 'Arcano', 'Tramonto']) {
      expect(AvvisiDelRito.spiegazione, contains(parola));
    }
  });

  test('I tre esiti del permesso restano tre', () {
    // La porta nuova passa da PortaDelPermesso come le altre due: se un
    // giorno gli esiti diventassero due, il "negato per sempre" sparirebbe e
    // la persona non saprebbe piu' che l'unica via sono le impostazioni.
    expect(EsitoDelPermesso.values, hasLength(4));
    expect(AppPermission.notifications.name, 'notifications');
    expect(Maestro.medora.id, 'medora');
  });
}
