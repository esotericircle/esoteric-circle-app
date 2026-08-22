import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I MAESTRI NON COPRONO PIU' NIENTE. Ordine AU voce 05.
///
/// **Il difetto, visto dal fondatore sullo screenshot della 2188**: dietro le
/// tre carte si leggono a meta' la riga del Maestro e l'invito "TOCCA IL
/// CIELO".
///
/// **LA CURA NON E' INVERTIRE L'ORDINE DI PILA**, e il commento gia' nel file
/// lo dice: se le due zone occupano gli stessi punti verticali, una copre
/// l'altra comunque, e col testo davanti sarebbe illeggibile al contrario. Le
/// due zone non si devono TOCCARE.
///
/// **Il vincolo va sui PIXEL DIPINTI e non sul rettangolo.** Le figure sbordano
/// dal proprio riquadro con `Clip.none`: restringere il carosello non sposta di
/// un punto cio' che si vede, ed e' un errore in cui questo repo e' gia'
/// caduto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  /// **TRE MISURE DI SCHERMO, UNA BASSA**, come l'ordine chiede: il pavimento
  /// di 220 punti si fa sentire proprio dove lo spazio manca, quindi provare
  /// solo su uno schermo comodo non proverebbe niente.
  /// **LE MISURE SONO IN PIXEL VERI CON IL LORO RAPPORTO VERO**, e la prima
  /// stesura sbagliava proprio qui: metteva rapporto 3 anche su un 720 per
  /// 1280, che e' un telefono a rapporto 2, e ne usciva uno schermo da 240
  /// punti di larghezza che non esiste. Una prova su un telefono immaginario
  /// trova difetti immaginari.
  const schermi = <String, (Size, double)>{
    'alto, 360x797': (Size(1080, 2391), 3.0),
    'medio, 375x667': (Size(750, 1334), 2.0),
    'basso, 320x568': (Size(640, 1136), 2.0),
  };

  Future<void> monta(WidgetTester tester, (Size, double) misura) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = misura.$1;
    tester.view.devicePixelRatio = misura.$2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    // **LA SCENA SI ASSESTA IN PIU' DI UN FOTOGRAMMA**, come gia' fanno
    // l'altezza della zona d'ingresso e quella del blocco del cielo: la misura
    // vera arriva dopo il primo disegno. Sul telefono sono millesimi; qui il
    // tempo non scorre da solo, quindi i fotogrammi si contano a mano.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Rect? scatolaDi(WidgetTester tester, Finder f) {
    final trovati = f.evaluate();
    if (trovati.isEmpty) return null;
    final ro = trovati.first.renderObject;
    if (ro is! RenderBox || !ro.hasSize || !ro.attached) return null;
    return ro.localToGlobal(Offset.zero) & ro.size;
  }

  /// I pixel in comune fra due scatole. Zero vuol dire che non si toccano.
  double copertiFra(Rect a, Rect b) {
    final i = a.intersect(b);
    if (i.width <= 0 || i.height <= 0) return 0;
    return i.width * i.height;
  }

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} i Maestri non coprono nessun testo',
        (tester) async {
      await monta(tester, voce.value);

      // **I QUATTRO TESTI CHE L'ORDINE NOMINA**, cercati per chiave dove ce
      // l'hanno e per contenuto dove no.
      final testi = <String, Rect?>{
        'titolo del cielo':
            scatolaDi(tester, find.byKey(const Key('santuario_sky_title'))),
        'riga personale': scatolaDi(
            tester, find.byKey(const Key('santuario_riga_personale'))),
        'riga della Luna': scatolaDi(
            tester,
            find.descendant(
                of: find.byKey(const Key('santuario_sky_tap')),
                matching: find.byType(Text))),
        'invito a toccare il cielo': scatolaDi(
            tester,
            find.byWidgetPredicate((w) =>
                w is Text &&
                (w.data ?? '').toUpperCase().contains('TOCCA IL CIELO'))),
      };

      final busti = <String, Rect?>{
        'Maestro centrale':
            scatolaDi(tester, find.byKey(const Key('santuario_central_bust'))),
        'Maestro di sinistra':
            scatolaDi(tester, find.byKey(const Key('santuario_side_left'))),
        'Maestro di destra':
            scatolaDi(tester, find.byKey(const Key('santuario_side_right'))),
      };

      // **UNA PROVA CHE NON TROVA NIENTE NON PROVA NIENTE.** Se i busti non ci
      // sono, l'occlusione fa zero per il motivo sbagliato: e' la stessa
      // trappola in cui e' caduta la guardia dello stacco, che contava widget
      // invece di guardare se erano dipinti.
      expect(busti.values.whereType<Rect>(), hasLength(3),
          reason: 'i tre Maestri non sono a schermo: la prova non sta '
              'guardando la scena che dice di guardare');
      expect(testi.values.whereType<Rect>().length, greaterThanOrEqualTo(3),
          reason: 'i testi del cielo non sono a schermo: $testi');

      // **LA MISURA CHE L'ORDINE CHIEDE PRIMA DELLA CURA**: quanto spazio
      // c'era davvero, e quanto se n'e' preso il busto.
      final misura = ultimaMisuraDelBusto;
      // ignore: avoid_print
      print('ORDINE AU VOCE 05: su ${voce.key} lo spazio concesso e '
          '${misura?.concessa.toStringAsFixed(1)} punti, il busto ne prende '
          '${misura?.busto.toStringAsFixed(1)}, su una scena alta '
          '${misura?.alta.toStringAsFixed(1)}');

      final guai = <String>[];
      var copertiInTutto = 0.0;
      for (final t in testi.entries) {
        final scatolaTesto = t.value;
        if (scatolaTesto == null) continue;
        for (final b in busti.entries) {
          final scatolaBusto = b.value;
          if (scatolaBusto == null) continue;
          final coperti = copertiFra(scatolaTesto, scatolaBusto);
          copertiInTutto += coperti;
          if (coperti > 0) {
            guai.add('${b.key} copre ${t.key} per '
                '${coperti.toStringAsFixed(0)} pixel');
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE AU VOCE 05: su ${voce.key} i pixel di testo coperti dai '
          'Maestri sono ${copertiInTutto.toStringAsFixed(0)}'
          '${guai.isEmpty ? "" : ", cioe $guai"}');
      // **DOVE LO SPAZIO C'E', ZERO. DOVE NON C'E', SI DICHIARA.**
      //
      // Su uno schermo alto, che e' quello da cui viene la segnalazione del
      // fondatore, lo spazio concesso al busto e' 188,7 punti e basta: zero
      // pixel coperti, e la prova lo pretende.
      //
      // Su uno schermo medio lo spazio concesso e' **67,8 punti** e su uno
      // basso e' **meno 24,2**: numeri sotto i quali non esiste nessuna
      // altezza del busto che vada bene, perche' il blocco del cielo e la zona
      // d'ingresso insieme occupano gia' tutta la scena. **Li' il difetto non
      // e' nel busto, e' nell'impaginazione del cielo**, ed e' materia che
      // l'Architetto deve decidere: comprimere il blocco del cielo cambia
      // cio' che si legge, e non si fa di nascosto dentro un'altra voce.
      //
      // **UNA VIA E' STATA PROVATA E BUTTATA**: allungare la scena e lasciarla
      // scorrere dava zero su tutte e tre le misure, ma spingeva i tre Maestri
      // sotto il bordo dello schermo e **tre prove di navigazione diventavano
      // rosse**, perche' il tocco sul busto centrale non apriva piu' il
      // dominio. Una home che per mostrare i Maestri chiede di scorrere non e'
      // piu' la home.
      //
      // Qui si pretende zero dove lo spazio esiste, e altrove si pretende che
      // non PEGGIORI: i due numeri sono quelli misurati il 22 agosto 2026.
      // **I NUMERI SONO CAMBIATI, E IN PEGGIO SU DUE SCHERMI SU TRE.** Ordine
      // AV voce 03, ed e' una scelta dichiarata e non una regressione subita.
      //
      // Il fondatore ha deciso che **lo spazio si prende dal cielo, mai dai
      // Maestri**: sono i protagonisti dell'app, e sulla 2189 erano scesi a
      // meta' della loro grandezza. Sul suo schermo la cura funziona su
      // entrambi i fronti, busto a 220 punti e **zero pixel coperti**. Su uno
      // schermo medio e su uno basso il busto grande copre di piu' di prima,
      // perche' li' lo spazio concesso e' 88,4 punti e **meno 3,6**: numeri
      // sotto i quali nessuna altezza del busto va bene, e la scelta e' fra
      // Maestri piccoli e testo coperto.
      //
      // **L'ordine prevede questo caso e lo ferma**: la voce AV.03 resta
      // FERMATA IN ATTESA DI DECISIONE coi due numeri, perche' su quegli
      // schermi la cura vera e' comprimere il blocco del cielo, e quella e'
      // una decisione dell'Architetto.
      const copertiOggi = <String, double>{
        'alto, 360x797': 0,
        'medio, 375x667': 9299,
        'basso, 320x568': 24768,
      };
      final tetto = copertiOggi[voce.key]!;
      if (tetto == 0) {
        expect(guai, isEmpty,
            reason: 'i Maestri stanno ancora sopra il testo su uno schermo che '
                'lo spazio ce l ha. Il rimedio non e invertire l ordine di '
                'pila: le due zone non si devono toccare');
      } else {
        // Un pixel di tolleranza: i numeri scritti sono arrotondati e la
        // misura ha i decimali, e cadere per nove centesimi di pixel non
        // segnala niente a nessuno.
        expect(copertiInTutto, lessThanOrEqualTo(tetto + 1),
            reason: 'su ${voce.key} i pixel coperti sono peggiorati: erano '
                '$tetto, adesso $copertiInTutto. Lo spazio li non basta per '
                'nessuna altezza del busto, ma non deve peggiorare');
      }
    });
  }
}
