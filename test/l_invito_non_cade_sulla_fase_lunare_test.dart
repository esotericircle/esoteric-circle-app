import 'package:esoteric_circle/features/santuario/widgets/moon_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// **L'INVITO AL CIELO NON CADE SUL NOME DELLA FASE.** Trovato a video sulla
/// build 2237, dispositivo 767f596c, 8 settembre 2026.
///
/// **Cosa si vedeva.** Sulla prima schermata dell'app, dentro il blocco del
/// cielo, la riga *"Tocca il cielo"* era stampata sopra *"LUNA CALANTE"*: due
/// scritte nello stesso posto, illeggibili tutte e due. Due catture a otto
/// secondi di distanza mostrano la stessa cosa, quindi non e' un fotogramma
/// di passaggio.
///
/// **PROVENIENZA: e' una regressione, e il codice lo dichiarava.** Sopra il
/// widget dell'invito c'era gia' scritto che *"cosi' com'era, la riga 'Tocca
/// il cielo' finiva sopra il nome della fase lunare"*, con la correzione che
/// lo spostava piu' in alto e piu' a destra. La correzione era una frazione
/// dell'altezza dello schermo, `top: h * 0.055`, mentre il nome della fase
/// vive dentro una colonna che parte da `top: h * 0.012` e **cresce col
/// titolo, col corpo di sistema e con la lingua**. Due catene indipendenti si
/// dividevano la stessa fascia, e nessuna delle due sapeva dov'era l'altra:
/// bastava che la colonna crescesse di qualche punto perche' le due scritte
/// si ritrovassero addosso.
///
/// **La grandezza misurata sono i due rettangoli dipinti, non le coordinate
/// che qualcuno ha scritto.** Si guarda se si incrociano. Una prova che
/// controllasse `top` resterebbe verde su qualunque valore, perche' il difetto
/// non sta in quel numero: sta nel rapporto fra due numeri che nessuno mette
/// mai a confronto.
///
/// **REGOLA H.** Non basta provare che le due scritte non si toccano: si
/// prova anche che l'invito **sia davvero a schermo** mentre lo si misura.
/// Due rettangoli non si incrociano benissimo anche quando uno dei due non
/// esiste, e sarebbe la guardia piu' verde e piu' inutile del registro.
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

  /// Il rettangolo VERO di un widget nello spazio dello schermo. Si passa per
  /// `getTransformTo`, non per `localToGlobal` piu' `size`: dentro un
  /// `FittedBox` o una scala le due cose non coincidono, e questo progetto ha
  /// gia' pagato una misura sbagliata per quel motivo.
  Rect rettangolo(WidgetTester tester, Finder chi) {
    final ro = tester.renderObject<RenderBox>(chi);
    return MatrixUtils.transformRect(
        ro.getTransformTo(null), Offset.zero & ro.size);
  }

  // **TRE SCHERMI, e il terzo e' quello che conta.** Il difetto e' nato dalla
  // colonna che cresce: su uno schermo basso cresce di piu' in proporzione, ed
  // e' li' che le due scritte si incontrano per prime.
  const schermi = <String, (Size, double)>{
    'alto, 360x797': (Size(1080, 2391), 3.0),
    'medio, 375x667': (Size(750, 1334), 2.0),
    'basso, 320x568': (Size(640, 1136), 2.0),
  };

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} l\'invito non tocca la fase lunare',
        (tester) async {
      silenzia();
      await montaLaHomePerLaMisura(tester, voce.value);

      // L'invito compare dopo tre secondi di immobilita': prima di allora
      // questa prova guarderebbe uno schermo dove non c'e'.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 600));

      final invito = find.byKey(const Key('santuario_invito_al_cielo'));
      final fase = find.byKey(const Key('santuario_fase_lunare'));
      // **REGOLA H, la meta' che rende la prova onesta.**
      expect(invito, findsOneWidget,
          reason: 'l\'invito al cielo non e\' a schermo: due rettangoli che '
              'non si incrociano perche\' uno non esiste non provano niente');
      expect(fase, findsOneWidget,
          reason: 'il nome della fase lunare non e\' a schermo');

      final a = rettangolo(tester, invito);
      final b = rettangolo(tester, fase);
      // **NON BASTA CHE NON SI INCROCINO, DEVONO STACCARSI.** Il primo giro
      // della riparazione chiedeva soltanto l'assenza di incrocio, e su
      // schermo medio le due scritte si sono fermate a **una frazione di
      // punto** l'una dall'altra: nessun incrocio, e a video due righe
      // appiccicate. La grandezza giusta e' il distacco, e si misura solo
      // dove i due rettangoli condividono delle colonne, perche' due scritte
      // che non si sovrappongono in orizzontale non si disturbano mai.
      final colonneInComune = a.left < b.right && b.left < a.right;
      final distacco = a.top >= b.bottom
          ? a.top - b.bottom
          : b.top >= a.bottom
              ? b.top - a.bottom
              : -1.0;
      // ignore: avoid_print
      print('INVITO E FASE, schermo ${voce.key}: invito '
          '${a.left.toStringAsFixed(1)},${a.top.toStringAsFixed(1)} '
          '${a.width.toStringAsFixed(1)}x${a.height.toStringAsFixed(1)}, '
          'fase ${b.left.toStringAsFixed(1)},${b.top.toStringAsFixed(1)} '
          '${b.width.toStringAsFixed(1)}x${b.height.toStringAsFixed(1)}, '
          'colonne in comune $colonneInComune, distacco '
          '${distacco.toStringAsFixed(1)}');
      if (colonneInComune) {
        expect(distacco, greaterThanOrEqualTo(4.0),
            reason: 'l\'invito "Tocca il cielo" e il nome della fase lunare '
                'condividono delle colonne e distano '
                '${distacco.toStringAsFixed(1)} punti: sulla prima schermata '
                'dell\'app due scritte finiscono l\'una addosso all\'altra, e '
                'un distacco negativo vuol dire che si sovrappongono');
      }

      // **REGOLA H, LA META' CHE GUARDA ALTROVE.** La riparazione ha spostato
      // l'invito sopra la Luna, e sopra la Luna c'e' il titolo del cielo:
      // aver tolto una sovrapposizione mettendone un'altra due righe piu' su
      // sarebbe il modo piu' facile di dichiarare chiuso un difetto che si e'
      // solo spostato. **Questa prova ha gia' visto quel rischio da vicino**:
      // il primo tentativo agganciava l'invito al fondo della Luna e faceva
      // salire di 645 pixel la copertura dei Maestri, cioe' riparava qui e
      // rompeva la' senza dirlo.
      final titolo = find.byKey(const Key('santuario_sky_title_testo'));
      expect(titolo, findsOneWidget,
          reason: 'il titolo del cielo non e\' a schermo');
      final t = rettangolo(tester, titolo);
      final colonneColTitolo = a.left < t.right && t.left < a.right;
      final distaccoDalTitolo = a.top >= t.bottom
          ? a.top - t.bottom
          : t.top >= a.bottom
              ? t.top - a.bottom
              : -1.0;
      // ignore: avoid_print
      print('INVITO E TITOLO, schermo ${voce.key}: titolo '
          '${t.left.toStringAsFixed(1)},${t.top.toStringAsFixed(1)} '
          '${t.width.toStringAsFixed(1)}x${t.height.toStringAsFixed(1)}, '
          'colonne in comune $colonneColTitolo, distacco '
          '${distaccoDalTitolo.toStringAsFixed(1)}');
      // **E NON COPRE LA LUNA.** Difetto visto a video sulla build 2238: il
      // primo tentativo compatto ancorava la mano a meta' del disco, e la
      // silhouette bianca ne copriva il quarto destro. Una scritta liberata
      // che si porta dietro un disegno addosso alla Luna non e' una
      // riparazione, e' uno scambio.
      final luna = find.byType(MoonWidget);
      expect(luna, findsWidgets, reason: 'la Luna non e\' a schermo');
      final l = rettangolo(tester, luna.first);
      // **SI MISURA LA MANO, non la scritta.** Il primo giro di questa
      // pretesa guardava il rettangolo del testo e restava verde mentre a
      // video la silhouette bianca copriva il quarto destro del disco: era la
      // famiglia del pezzo sano misurato accanto al pezzo rotto.
      final mano = find.byKey(const Key('santuario_mano_dell_invito'));
      expect(mano, findsOneWidget,
          reason: 'la mano dell invito non e a schermo');
      final m = rettangolo(tester, mano);
      final sullaLuna = m.intersect(l);
      final copreLaLuna = sullaLuna.width > 0 && sullaLuna.height > 0;
      // **E LA SCRITTA STA IN DUE RIGHE.** A settanta punti di larghezza
      // "Tocca il cielo" entra in due righe; a cinquantotto ne prendeva tre,
      // e tre righe alzano il gruppo fin sopra il titolo. Si contano le righe
      // dipinte, non i caratteri.
      final ro = tester.renderObject<RenderParagraph>(invito);
      final righeDipinte = ro
          .getBoxesForSelection(TextSelection(
              baseOffset: 0, extentOffset: ro.text.toPlainText().length))
          .map((b) => b.top.round())
          .toSet()
          .length;
      // ignore: avoid_print
      print('INVITO E LUNA, schermo ${voce.key}: Luna '
          '${l.left.toStringAsFixed(1)},${l.top.toStringAsFixed(1)} '
          '${l.width.toStringAsFixed(1)}x${l.height.toStringAsFixed(1)}, '
          'copre la Luna $copreLaLuna, righe della scritta $righeDipinte');
      expect(copreLaLuna, isFalse,
          reason: 'l\'invito copre la Luna per '
              '${sullaLuna.width.toStringAsFixed(1)} punti per '
              '${sullaLuna.height.toStringAsFixed(1)}: la mano sta addosso al '
              'disco invece che accanto');
      expect(righeDipinte, lessThanOrEqualTo(2),
          reason: 'la scritta dell\'invito occupa $righeDipinte righe: il '
              'gruppo cresce in altezza e torna a toccare cio\' che ha sopra');

      // **E STA DENTRO LO SCHERMO.** L invito e cresciuto in larghezza per
      // stare in due righe invece che in tre, e su schermo stretto il bordo
      // destro e vicino: una scritta tagliata dal bordo sarebbe il terzo modo
      // di rendere illeggibile la stessa riga.
      final larghezzaSchermo = tester.view.physicalSize.width /
          tester.view.devicePixelRatio;
      // ignore: avoid_print
      print("INVITO E BORDO, schermo " + voce.key + ": destro " +
          a.right.toStringAsFixed(1) + " su " +
          larghezzaSchermo.toStringAsFixed(1));
      expect(a.right, lessThanOrEqualTo(larghezzaSchermo),
          reason: "l invito esce dal bordo destro dello schermo");
      expect(a.left, greaterThanOrEqualTo(0.0),
          reason: "l invito esce dal bordo sinistro dello schermo");

      if (!colonneColTitolo) return;
      expect(distaccoDalTitolo, greaterThanOrEqualTo(4.0),
          reason: 'l\'invito "Tocca il cielo" e il titolo del cielo '
              'condividono delle colonne e distano '
              '${distaccoDalTitolo.toStringAsFixed(1)} punti: la '
              'sovrapposizione si e\' spostata piu\' in alto invece di '
              'sparire');
    });
  }
}
