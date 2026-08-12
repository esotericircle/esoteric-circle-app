import 'package:esoteric_circle/core/astro/solar_time.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/services/apertura_delle_chiamate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE CHIAMATE DEL GIORNO, ordine M voce 2j. Tre guardie:
///
/// 1. nessuna chiamata parte senza un fatto vero: un mattino senza transiti
///    non manda niente, perche' zero sta sopra il rumore;
/// 2. mai piu' del numero dichiarato in un giorno, e il numero vive in un
///    dato solo, `AvvisiDelRito.chiamateAlGiorno`;
/// 3. ogni canale apre la SUA scena, mai la home: il carico dell'avviso
///    porta al tramonto, all'oroscopo o all'Estrazione Rune.
class _AvvisiRegistrati extends ServizioAvvisi {
  final List<
      ({
        int id,
        DateTime quando,
        String titolo,
        String testo,
        String canale,
        String carico
      })> programmati = [];

  @override
  bool get disponibile => true;

  @override
  Future<bool> chiediPermesso() async => true;

  @override
  Future<bool> permessoConcesso() async => true;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {
    programmati.add((
      id: id,
      quando: quando,
      titolo: titolo,
      testo: testo,
      canale: canale,
      carico: carico,
    ));
  }

  @override
  Future<void> annulla(int id) async {
    programmati.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<int>> inAttesa() async =>
      programmati.map((p) => p.id).toList(growable: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Un mezzogiorno qualunque, col tramonto davanti.
  final adesso = DateTime(2026, 8, 11, 12);
  final tramonto = DateTime(2026, 8, 11, 20, 30);
  final tramontoDiDomani = DateTime(2026, 8, 12, 20, 29);

  group('Guardia 1: senza un fatto vero il mattino tace', () {
    test('cielo piatto e gettate intere: parte solo la sera', () async {
      final servizio = _AvvisiRegistrati();
      final programmate = await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: servizio,
        adesso: adesso,
        tramonto: tramonto,
        tramontoDiDomani: tramontoDiDomani,
        fattoDiDomani: null,
        gettateEsaurite: false,
      );
      expect(programmate, [AvvisiDelRito.idChiamataDellaSera],
          reason: 'Con un cielo senza transiti il mattino deve tacere: una '
              'chiamata inventata e\' rumore, non un fatto.');
      expect(servizio.programmati, hasLength(1));
      expect(servizio.programmati.single.canale, AvvisiDelRito.canaleTramonto,
          reason: 'L\'unica chiamata del giorno piatto e\' quella della sera.');
    });

    test('un fatto fatto di soli spazi vale come nessun fatto', () async {
      final servizio = _AvvisiRegistrati();
      await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: servizio,
        adesso: adesso,
        tramonto: tramonto,
        tramontoDiDomani: tramontoDiDomani,
        fattoDiDomani: '   ',
        gettateEsaurite: false,
      );
      expect(
          servizio.programmati
              .where((p) => p.id == AvvisiDelRito.idChiamataDelMattino),
          isEmpty,
          reason: 'Una stringa vuota non e\' un fatto vero, e il mattino ha '
              'chiamato lo stesso.');
    });

    test('col fatto vero il mattino parla, e dice QUEL fatto', () async {
      const fatto = 'Oggi Marte forma un trigono al tuo Sole.';
      final servizio = _AvvisiRegistrati();
      await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: servizio,
        adesso: adesso,
        tramonto: tramonto,
        tramontoDiDomani: tramontoDiDomani,
        fattoDiDomani: fatto,
        gettateEsaurite: false,
      );
      final mattino = servizio.programmati
          .singleWhere((p) => p.id == AvvisiDelRito.idChiamataDelMattino);
      expect(mattino.testo, fatto,
          reason: 'La chiamata del mattino deve portare il transito vero, '
              'non una frase di circostanza.');
      expect(mattino.canale, AvvisiDelRito.canaleOroscopo);
      expect(mattino.carico, AvvisiDelRito.caricoOroscopo);
      expect(mattino.quando,
          SunsetTime.oraMediaAlba(adesso.add(const Duration(days: 1))),
          reason: 'Il fatto di domani suona domattina, non a un\'ora a caso.');
    });
  });

  group('Guardia 2: mai piu\' del numero dichiarato', () {
    test('anche col giorno piu\' pieno le chiamate restano nel numero',
        () async {
      // Il giorno piu' pieno possibile: tramonto davanti, gettate esaurite
      // E un fatto vero. Tre voci vorrebbero parlare, il numero dice due.
      final servizio = _AvvisiRegistrati();
      final programmate = await AvvisiDelRito.programmaLeChiamateDelGiorno(
        servizio: servizio,
        adesso: adesso,
        tramonto: tramonto,
        tramontoDiDomani: tramontoDiDomani,
        fattoDiDomani: 'Oggi Venere forma un sestile alla tua Luna.',
        gettateEsaurite: true,
      );
      expect(servizio.programmati.length,
          lessThanOrEqualTo(AvvisiDelRito.chiamateAlGiorno),
          reason: 'Sono partite piu\' chiamate del numero dichiarato nel '
              'dato: la persona riceve rumore.');
      expect(programmate.toSet(), {
        AvvisiDelRito.idChiamataDellaSera,
        AvvisiDelRito.idChiamataDelMattino,
      });
      // E il mattino e' UNO: le gettate tornate vincono sull'oroscopo,
      // perche' parlano di un limite toccato ieri con le proprie mani.
      final mattino = servizio.programmati
          .where((p) => p.id == AvvisiDelRito.idChiamataDelMattino);
      expect(mattino, hasLength(1));
      expect(mattino.single.canale, AvvisiDelRito.canaleGettate,
          reason: 'A gettate esaurite il mattino deve parlare del ritorno '
              'delle gettate, non dell\'oroscopo.');
    });

    test('il numero vive in un dato solo, e vale tre', () {
      // TRE dall'ordine O del 12 agosto 2026, per decisione di Mauro: erano
      // due, e la terza voce e' il traguardo a un passo, che parte solo se un
      // traguardo e' davvero vicino.
      expect(AvvisiDelRito.chiamateAlGiorno, 3,
          reason: 'Il numero delle chiamate del giorno e\' un dato di '
              'prodotto: se cambia, deve cambiare per scelta e non per caso.');
    });
  });

  group('Guardia 3: ogni canale apre la sua scena, mai la home', () {
    // La scena vera sta sotto le soglie di rotta: si scarta l'involucro
    // (MaestroScope o SogliaArte) e si guarda chi c'e' dentro.
    Widget scenaDi(Route<void>? rotta, BuildContext ctx) {
      expect(rotta, isNotNull,
          reason: 'Un carico conosciuto deve avere la sua rotta: senza, il '
              'tocco sull\'avviso lascia la persona sulla home.');
      Widget dentro = (rotta! as MaterialPageRoute<void>).builder(ctx);
      while (dentro is MaestroScope || dentro is SogliaArte) {
        dentro = dentro is MaestroScope
            ? dentro.child
            : (dentro as SogliaArte).child;
      }
      return dentro;
    }

    testWidgets('tramonto, oroscopo e gettate portano ciascuno da se\'',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      late BuildContext ctx;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: MaterialApp(
            home: Builder(builder: (c) {
              ctx = c;
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(
          scenaDi(
              AperturaDelleChiamate.rottaPer(
                  AvvisiDelRito.caricoTramonto, ctx),
              ctx),
          isA<SunsetRuneScreen>(),
          reason: 'La Runa del Tramonto promette il tramonto e deve aprire '
              'il tramonto.');
      expect(
          scenaDi(
              AperturaDelleChiamate.rottaPer(
                  AvvisiDelRito.caricoOroscopo, ctx),
              ctx),
          isA<OroscopoScreen>(),
          reason: 'Il cielo di oggi promette l\'oroscopo e deve aprire '
              'l\'oroscopo.');
      expect(
          scenaDi(
              AperturaDelleChiamate.rottaPer(AvvisiDelRito.caricoGettate, ctx),
              ctx),
          isA<RuneDrawScreen>(),
          reason: 'Le gettate tornate promettono l\'Estrazione Rune e devono '
              'aprire l\'Estrazione Rune.');
      // Un carico sconosciuto non apre niente: mai un crash per un avviso
      // vecchio rimasto nel sistema.
      expect(
          AperturaDelleChiamate.rottaPer('carico_che_non_esiste', ctx), isNull);
    });
  });
}
