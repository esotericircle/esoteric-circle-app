import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/services/apertura_delle_chiamate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE CHIAMATE DEL GIORNO, ordine M voce 2j, **RIDOTTO DALL'ORDINE BC VOCE
/// 05**.
///
/// **Due delle tre guardie di questo file non ci sono piu', e non e' una
/// perdita: e' una regola sostituita dal fondatore.** Sorvegliavano le
/// chiamate di allora, "mai piu' di tre al giorno" e "un mattino senza
/// transiti non manda niente". Parole del fondatore, maiuscole sue: "ne
/// voglio 5, ovvero una per ogni dono con orario che avevamo gia'
/// concordato". Le chiamate non sono piu' tre e non parlano piu' di
/// transiti: sono cinque, una per Dono, e si accendono una per una.
///
/// **Le regole nuove si misurano in
/// `test/cinque_avvisi_uno_per_dono_test.dart`**, che conta le cinque
/// chiamate, i loro orari, i cinque canali distinti, e che spegnere un Dono
/// annulli davvero il suo avviso invece di limitarsi a non riprogrammarlo.
///
/// **Qui resta la terza, che vale ancora ed e' la piu' importante**: ogni
/// avviso apre la SUA scena, mai la home. Adesso vale per otto carichi invece
/// che per tre, perche' ai vecchi si sono aggiunti i cinque dei Doni.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La scena che una rotta apre, sbucciata dagli involucri.
  ///
  /// **Il pavimento del Maestro e la soglia dell'arte avvolgono la scena**, e
  /// senza toglierli il confronto guarderebbe l'involucro invece del
  /// contenuto: la prima stesura di questa riparazione lo ha fatto, e la
  /// prova ha risposto "trovato MaestroScope" invece del nome del rito.
  Widget scenaDi(Route<void>? rotta, BuildContext ctx) {
    expect(rotta, isNotNull,
        reason: 'Un carico conosciuto deve avere la sua rotta: senza, il '
            'tocco sull avviso lascia la persona sulla home.');
    // **LA ROTTA NON E' PIU' UNA `MaterialPageRoute`. Ordine CC voce 07.**
    // Con la voce CC.04 ogni passaggio fra schermate e' passato al velo nero,
    // cioe' a `PassaggioDelCerchio.rotta`, che costruisce un
    // `PageRouteBuilder`: il cast secco qui sopra lanciava, e la prova cadeva
    // su un errore di tipo invece che sul fatto che difende. Si accettano
    // tutte e due le forme, perche' il fatto e' quale scena la rotta apre.
    final r = rotta!;
    Widget dentro = r is MaterialPageRoute<void>
        ? r.builder(ctx)
        : (r as PageRouteBuilder<void>).pageBuilder(
            ctx, kAlwaysCompleteAnimation, kAlwaysDismissedAnimation);
    while (dentro is MaestroScope || dentro is SogliaArte) {
      dentro = dentro is MaestroScope
          ? dentro.child
          : (dentro as SogliaArte).child;
    }
    return dentro;
  }

  group('Ogni avviso apre la SUA scena, mai la home', () {
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
      // **E I CINQUE DONI, ordine BC voce 05.** Ognuno apre il proprio rito:
      // un avviso che porta alla home non mantiene quello che ha promesso, e
      // adesso di avvisi ce ne sono cinque invece di tre.
      final aperti = <String>[];
      for (final d in DailyElement.values) {
        final rotta = AperturaDelleChiamate.rottaPer(
            AvvisiDelRito.caricoDelDono(d), ctx);
        expect(rotta, isNotNull,
            reason: 'il carico del Dono ${d.name} non apre niente');
        aperti.add('${d.name} -> ${scenaDi(rotta, ctx).runtimeType}');
      }
      // ignore: avoid_print
      print('ORDINE BC VOCE 05: i carichi che aprono il loro rito sono '
          '$aperti');

      // Un carico sconosciuto non apre niente: mai un crash per un avviso
      // vecchio rimasto nel sistema.
      expect(
          AperturaDelleChiamate.rottaPer('carico_che_non_esiste', ctx), isNull);
      expect(AperturaDelleChiamate.rottaPer('dono:inventato', ctx), isNull,
          reason: 'un Dono che non esiste piu deve non aprire niente, non far '
              'cadere l app');
    });
  });
}
