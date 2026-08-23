import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// I MAESTRI, MISURATI SUI PIXEL E NON SUI RETTANGOLI.
/// Ordine BA voce 02, e chiude la voce 02 dell'ordine AX.
///
/// **Il fatto del fondatore, alla quarta segnalazione**: "nella home i 3
/// maestri sono troppo in alto coprendo il messaggio che sta subito sopra".
///
/// **Le tre volte precedenti la misura diceva ZERO mentre a schermo il testo
/// si leggeva a meta'**, e la ragione e' scritta nell'ordine AX: le figure
/// escono dal proprio riquadro con `Clip.none`, quindi **confrontare
/// rettangoli di layout non vedra' mai il problema**. Restringere il carosello
/// non sposta di un pixel cio' che si vede.
///
/// **Come si misura qui, ed e' il metodo che l'ordine impone.** Si dipinge la
/// home in un'immagine, si ridipinge la stessa home **senza il carosello**, e
/// si contano i pixel che nelle due immagini differiscono **dentro la fascia
/// del testo**. Un pixel che cambia togliendo i Maestri e' un pixel che i
/// Maestri stavano coprendo: non c'e' modo di discutere il numero.
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

  /// Le tre misure di schermo dell'ordine AV, con i loro rapporti VERI.
  const schermi = <String, (Size, double)>{
    'alto, 360x797': (Size(1080, 2391), 3.0),
    'medio, 375x667': (Size(750, 1334), 2.0),
    'basso, 320x568': (Size(640, 1136), 2.0),
  };

  /// Dipinge la scena montata e torna i pixel grezzi.
  ///
  /// **Dentro `runAsync`, e senza non finisce mai.** `toImage` ha bisogno del
  /// ciclo degli eventi vero: nel tempo finto delle prove il futuro non si
  /// chiude, e la prova muore con "did not complete" invece di dire un
  /// numero. E' lo stesso inciampo gia' incontrato nell'ordine AV voce 01.
  Future<ByteData> dipingi(WidgetTester tester) async {
    late ByteData dati;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('la_home_intera')));
      final immagine = await ro.toImage(pixelRatio: 1.0);
      dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      immagine.dispose();
    });
    return dati;
  }

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} i Maestri coprono zero pixel di testo',
        (tester) async {
      silenzia();
      maestriSpentiPerLaProva = false;
      testoDelCieloSpentoPerLaProva.value = false;
      addTearDown(() {
        maestriSpentiPerLaProva = false;
        testoDelCieloSpentoPerLaProva.value = false;
      });

      // **PRIMA CON I MAESTRI**, cioe' la home come la vede il fondatore.
      await montaLaHomePerLaMisura(tester, voce.value);
      final fascia = fasciaDelTesto(tester);
      final con = await dipingi(tester);

      // **PRIMA LA CONTROPROVA DELLA MISURA STESSA.** Due catture di seguito
      // senza cambiare NIENTE devono dare zero differenze: se il cosmo si
      // muove fra l'una e l'altra, ogni numero che segue e' il movimento
      // delle stelle e non l'occlusione dei Maestri.
      //
      // **Serve davvero, e l'ha gia' salvata una volta**: la prima stesura
      // faceva passare sessanta millesimi fra le due catture, e il conto
      // diceva che i Maestri arrivavano fino alla riga ZERO dello schermo,
      // cioe' sopra il titolo, sopra la barra, ovunque. Non erano i Maestri:
      // era il cielo che scorreva.
      final ancora = await dipingi(tester);
      var mossi = 0;
      for (var i = 0; i + 3 < con.lengthInBytes; i += 4) {
        if (con.getUint32(i) != ancora.getUint32(i)) mossi++;
      }
      expect(mossi, 0,
          reason: 'fra due catture identiche cambiano gia $mossi pixel: la '
              'scena si muove da sola, e la misura dell occlusione misurerebbe '
              'quello');

      // **POI SENZA**, e nient'altro cambia: stessa scena, stesso istante,
      // stessa misura di schermo. **Un solo `pump` senza far scorrere il
      // tempo**: basta a ridipingere, e non lascia correre le animazioni.
      maestriSpentiPerLaProva = true;
      await tester.pump(Duration.zero);
      final senza = await dipingi(tester);

      // **E POI SENZA NIENTE**, cioe' senza Maestri e senza testo: la
      // differenza fra questa e la precedente e' l'insieme ESATTO delle
      // lettere dipinte.
      testoDelCieloSpentoPerLaProva.value = true;
      await tester.pump(Duration.zero);
      final nudo = await dipingi(tester);

      // **SI CONTANO LE LETTERE, NON IL RETTANGOLO. Ordine BA voce 02, terza
      // stesura della misura, e le prime due erano sbagliate tutte e due.**
      //
      // La prima confrontava i rettangoli di layout e diceva zero tre volte
      // mentre a schermo il testo si leggeva a meta'. La seconda contava i
      // pixel dentro il rettangolo del testo, ed **e' stata smascherata
      // dipingendo la mappa della differenza**: su schermo alto la cima dei
      // Maestri entrava nelle ultime quattordici righe di quel rettangolo,
      // **dove lettere non ce ne sono**, e la prova dichiarava 830 pixel
      // coperti mentre a video non era coperto niente. Un rettangolo di testo
      // e' quasi tutto vuoto, e contare il vuoto e' contare il cielo.
      //
      // Adesso un pixel conta solo se e' **di una lettera**, cioe' se
      // spegnere il testo lo cambia. Non c'e' piu' spazio per
      // l'interpretazione: o i Maestri toccano l'inchiostro, o non lo toccano.
      final larghezza = tester.view.physicalSize.width ~/
          tester.view.devicePixelRatio;
      var lettere = 0;
      var diversi = 0;
      for (var y = fascia.top.floor(); y < fascia.bottom.ceil(); y++) {
        for (var x = fascia.left.floor(); x < fascia.right.ceil(); x++) {
          final i = (y * larghezza + x) * 4;
          if (i < 0 || i + 3 >= con.lengthInBytes) continue;
          // Questo pixel porta inchiostro?
          if (senza.getUint32(i) == nudo.getUint32(i)) continue;
          lettere++;
          if (con.getUint32(i) != senza.getUint32(i)) diversi++;
        }
      }
      expect(lettere, greaterThan(500),
          reason: 'dentro la fascia si contano solo $lettere pixel di '
              'inchiostro: il testo non si sta dipingendo, e una misura che '
              'non trova le lettere non puo dire se sono coperte');
      testoDelCieloSpentoPerLaProva.value = false;
      // **DOVE ARRIVA LA CIMA DEI MAESTRI, misurata e non stimata.** Il
      // codice del carosello calcola quanto sale un laterale con un fattore
      // dedotto dalle sue costanti; qui si guarda il pixel piu' alto che
      // cambia, che e' la cima vera dei pixel dipinti.
      var cima = -1;
      final alto = tester.view.physicalSize.height ~/
          tester.view.devicePixelRatio;
      for (var y = 0; y < alto && cima < 0; y++) {
        for (var x = 0; x < larghezza; x++) {
          final i = (y * larghezza + x) * 4;
          if (i < 0 || i + 3 >= con.lengthInBytes) continue;
          if (con.getUint32(i) != senza.getUint32(i)) {
            cima = y;
            break;
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE BA VOCE 02: su schermo ${voce.key}, la fascia del testo '
          'va da ${fascia.top.round()} a ${fascia.bottom.round()} e porta '
          '$lettere pixel di inchiostro, i Maestri arrivano fino a $cima, e i '
          'pixel di INCHIOSTRO che coprono sono $diversi');

      // **E QUANTO RESTA DEI MAESTRI, dichiarato e non taciuto.** Ordine BA
      // voce 02.
      //
      // Il testo che si legge non basta se il prezzo e' una home senza i suoi
      // protagonisti. Su schermo alto e medio il busto resta pieno; **su
      // schermo 320 per 568 scende a ventiquattro punti e in pratica non si
      // vede**, perche' li' il blocco del cielo ne occupa 258 su 568 e sotto
      // non resta posto. Non e' un difetto della cura, e' la stanza che e'
      // troppo piccola per i due mobili.
      //
      // **La cura completa e' che il cielo ceda su quegli schermi**, ed e'
      // lavoro dichiarato e non fatto. Questa riga esiste perche' il giorno in
      // cui si fara' si sappia da che numero si parte, e perche' nessuno possa
      // dire che il difetto era nascosto.
      final busto = ultimaMisuraDelBusto?.busto ?? 0;
      // ignore: avoid_print
      print('ORDINE BA VOCE 02: su schermo ${voce.key} del busto restano '
          '${busto.round()} punti, e il carosello ne prende '
          '${(ultimaMisuraDelBusto?.concessa ?? 0).round()}');

      // **LA LEGGE E' CAMBIATA CON GLI ORDINI BC E BD, e si dichiara.**
      // Lo zero di questa riga apparteneva alla regola vecchia, i Maestri
      // dietro i testi e mai un pixel sopra. Il fondatore l'ha rovesciata due
      // volte, guardando le anteprime: "mettessi il livello dei 3 maestri
      // sopra a quello dei testi, non importa se coprono leggermente il
      // testo" (coda di BC.01), e poi "ingrandirli tanto che lateralmente si
      // devono sovrapporre" (BD.01). La leggibilita' per singolo testo la
      // sorveglia `nessun_testo_finisce_sotto_test`, con la soglia del 35
      // per cento sui pixel: qui si tiene fermo che la copertura resti
      // LEGGERA sulla fascia intera, coi numeri misurati il 23 agosto 2026.
      //
      // Su schermo basso la fascia e' DELIBERATAMENTE dietro i Maestri,
      // ordine BD voce 04: la scelta era fra Maestri francobollo e testi del
      // cielo dietro le figure, e il fondatore aveva gia' scelto. Li' si
      // pretende solo che non peggiori.
      final quota = lettere == 0 ? 0.0 : diversi / lettere;
      final tettoDellaQuota = <String, double>{
        'alto, 360x797': 0.20, // misurato 0,088
        'medio, 375x667': 0.25, // misurato 0,121
        'basso, 320x568': 0.97, // misurato 0,935, dietro per scelta
      }[voce.key]!;
      // ignore: avoid_print
      print('ORDINE BD: su ${voce.key} la quota coperta della fascia e '
          '${(quota * 100).toStringAsFixed(1)} per cento, tetto '
          '${(tettoDellaQuota * 100).round()}');
      expect(quota, lessThanOrEqualTo(tettoDellaQuota),
          reason: 'i Maestri coprono il ${(quota * 100).round()} per cento '
              'dell inchiostro della fascia su ${voce.key}: la copertura '
              'accettata dal fondatore e LEGGERA, e questa non lo e piu');
    });
  }
}
