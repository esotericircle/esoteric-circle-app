import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_lente_che_scopre.dart';

/// **LA GUARDIA DELLA VOCE DE.03, sotto la Regola H.**
///
/// *"Alla prima, seconda e terza discesa la prova dimostra che nessun pixel
/// del rettangolo della testa risulta mai scoperto, per tutti e dodici gli
/// animali, e che alla quarta lo e'."*
///
/// **LE DUE META', e la seconda e' quella che fa di questa una guardia.** La
/// prima dimostra che la testa resta coperta. Da sola sarebbe verde anche se
/// la lente non si aprisse mai, e una lente che non si apre non e' una lente.
/// La seconda dimostra che **alla quarta la testa e' raggiungibile**, cioe'
/// che il velo cade davvero.
void main() {
  /// **QUANTE POSIZIONI DEL DITO SI PROVANO PER OGNI ANIMALE E DISCESA.**
  ///
  /// Ventuno per ventuno, e **fuori dai bordi**: da meno mezzo a uno e mezzo,
  /// cosi' la prova include il caso che conta davvero, cioe' **il dito che
  /// spinge oltre il confine**. Un dito che si muove solo dentro l'area non
  /// puo' scoprire niente di proibito, e una prova che gli dia solo quelli
  /// misura la propria cortesia.
  const quanti = 21;
  const da = -0.5;
  const a = 1.5;

  /// La scena di prova: un telefono vero, non gli ottocento per seicento di
  /// fabbrica. Vedi la memoria della finestra di prova irreale.
  const scena = Size(390, 844);

  test('REGOLA H, PRIMA META: nella prima, seconda e terza discesa la lente '
      'non tocca MAI il rettangolo della testa, per tutti e dodici', () {
    // **IL CARDINALE MINIMO, che questa guardia dichiara.** Dodici animali nel
    // catalogo, dodici righe nel file delle teste: se un giorno ne arrivasse
    // un tredicesimo senza la sua riga, la lente non saprebbe dove non
    // guardare, e questa prova cade col numero in mano.
    expect(DoveStaLaTesta.quantiSono, AnimalCatalog.animals.length,
        reason: 'il file delle teste e il catalogo non hanno lo stesso numero '
            'di animali: uno dei due ha una riga che l\'altro non ha');
    expect(DoveStaLaTesta.quantiSono, 12);

    var provate = 0;
    var peggiore = double.infinity;
    String dovePeggiore = '';

    for (final animale in AnimalCatalog.animals) {
      final testa = DoveStaLaTesta.di(animale.name);
      expect(testa, isNotNull,
          reason: '${animale.name} non ha il rettangolo della testa: la lente '
              'non sa dove non guardare, e lo scoprirebbe per caso');

      // Il rettangolo dell'immagine dentro la scena, come `BoxFit.contain`.
      final k = scena.width / 900 < scena.height / 760
          ? scena.width / 900
          : scena.height / 760;
      final immagine = Rect.fromLTWH((scena.width - 900 * k) / 2,
          (scena.height - 760 * k) / 2, 900 * k, 760 * k);
      final raggio = immagine.width * DoveStaLaTesta.raggioDellaLente;
      final testaInPunti = Rect.fromLTRB(
        immagine.left + immagine.width * testa!.left,
        immagine.top + immagine.height * testa.top,
        immagine.left + immagine.width * testa.right,
        immagine.top + immagine.height * testa.bottom,
      );

      for (var discesa = 0; discesa < 3; discesa++) {
        final area = DoveStaLaTesta.areaDellaDiscesa(animale.name, discesa);
        for (var ix = 0; ix < quanti; ix++) {
          for (var iy = 0; iy < quanti; iy++) {
            final dito = Offset(
              immagine.left + immagine.width * (da + (a - da) * ix / (quanti - 1)),
              immagine.top + immagine.height * (da + (a - da) * iy / (quanti - 1)),
            );
            final centro = DoveStaLaTesta.tieniDentro(
                dito: dito, immagine: immagine, area: area, raggio: raggio);
            final cerchio = Rect.fromCircle(center: centro, radius: raggio);
            provate++;
            // **QUANTO MANCA perche' il cerchio tocchi la testa.** Positivo
            // vuol dire che non la tocca.
            final margine = cerchio.top - testaInPunti.bottom;
            if (margine < peggiore) {
              peggiore = margine;
              dovePeggiore = '${animale.name}, discesa ${discesa + 1}';
            }
            expect(cerchio.overlaps(testaInPunti), isFalse,
                reason: 'alla discesa ${discesa + 1} di ${animale.name} la '
                    'lente centrata in $centro scopre il rettangolo della '
                    'testa $testaInPunti: il nome dell\'animale si legge '
                    'prima della quarta discesa');
          }
        }
      }
    }

    // ignore: avoid_print
    print('ORDINE DE VOCE 03: provate $provate posizioni della lente; il caso '
        "piu' stretto e' $dovePeggiore, dove fra la cima della lente "
        'e il fondo della testa restano ${peggiore.toStringAsFixed(1)} punti');
    expect(provate, 12 * 3 * quanti * quanti,
        reason: 'la prova ha guardato meno posizioni di quante ne aveva '
            "promesse: un ciclo si e' fermato prima");
    expect(peggiore, greaterThan(0),
        reason: 'in qualche caso la lente arriva a toccare la testa');
  });

  test("REGOLA H, SECONDA META: alla QUARTA discesa la lente ARRIVA sulla "
      "testa, per tutti e dodici", () {
    // **Senza questa meta' la prima sarebbe verde anche con la lente
    // spenta.** Una lente che non si apre mai copre la testa benissimo.
    //
    // **LA QUARTA E' LA DISCESA DELLA TESTA**, e non piu' la discesa in cui
    // non c'e' niente da scoprire. Ordine DG, 12 settembre 2026: *"solo
    // l'ultimo giorno la lente scoprira' la testa dell'animale"*. Prima qui
    // si pretendeva l'immagine intera, cioe' **il velo caduto**: il quarto
    // giorno l'animale si vedeva tutto senza passare la lente, e la lente non
    // scopriva niente perche' non c'era piu' niente da scoprire.
    for (final animale in AnimalCatalog.animals) {
      final testa = DoveStaLaTesta.di(animale.name)!;
      final area = DoveStaLaTesta.areaDellaDiscesa(animale.name, 3);
      expect(area.top, 0,
          reason: 'alla quarta discesa la lente di ${animale.name} non '
              'arriva in cima: la testa resterebbe fuori');
      expect(area.bottom, DoveStaLaTesta.sottoLaTesta(animale.name),
          reason: "alla quarta discesa l'area di ${animale.name} non e la sua "
              'testa: o e tutta l immagine, e allora non c e niente da '
              'scoprire, o e una fascia sbagliata');
      // E il centro della testa e' dentro l'area concessa.
      expect(area.contains(testa.center), isTrue,
          reason: 'alla quarta discesa il centro della testa di '
              "${animale.name} sta fuori dall'area concessa");
      // **E DOPO LA QUARTA non c'e' piu' nessun limite**: e' lo stato della
      // card della rivelazione, dove l'animale si vede intero.
      expect(DoveStaLaTesta.areaDellaDiscesa(animale.name, 4),
          const Rect.fromLTRB(0, 0, 1, 1),
          reason: 'dopo la quarta discesa ${animale.name} ha ancora un '
              'limite: il velo non cade mai');
    }
  });

  test('LE TRE AREE STANNO TUTTE SOTTO LA TESTA, e sono tre fasce distinte',
      () {
    for (final animale in AnimalCatalog.animals) {
      final sotto = DoveStaLaTesta.sottoLaTesta(animale.name);
      Rect? prima;
      for (var d = 0; d < 3; d++) {
        final area = DoveStaLaTesta.areaDellaDiscesa(animale.name, d);
        expect(area.top, greaterThanOrEqualTo(sotto - 0.0001),
            reason: "l'area della discesa ${d + 1} di ${animale.name} "
                "comincia sopra il punto piu' basso della testa");
        expect(area.height, greaterThan(0.01),
            reason: "l'area della discesa ${d + 1} di ${animale.name} e' "
                "alta quasi zero: quella discesa non scopre niente");
        if (prima != null) {
          expect(area.top, lessThan(prima.top),
              reason: 'le aree non salgono: la discesa ${d + 1} di '
                  '${animale.name} non sta sopra la precedente');
        }
        prima = area;
      }
    }
  });

  testWidgets("IL VELO C'E' NELLE PRIME TRE DISCESE E NON C'E' "
      "ALLA QUARTA", (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> apri(int discesa) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LenteCheScopre(
            nome: 'Lupo',
            immagine: AnimalCatalog.animals.first.fullPath,
            discesa: discesa,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));
    }

    final velo = find.byKey(const Key('viaggio_velo_dell_animale'));
    // **IL VELO C'E' IN TUTTE E QUATTRO LE DISCESE**, e alla quarta copre la
    // sola testa: ordine DG, 12 settembre 2026.
    for (var d = 0; d <= DoveStaLaTesta.quanteFasce; d++) {
      await apri(d);
      // ignore: avoid_print
      print('ORDINE DE VOCE 03: alla discesa ${d + 1} i veli a schermo sono '
          '${velo.evaluate().length}');
      expect(velo, findsOneWidget,
          reason: "alla discesa ${d + 1} non c'e' nessun velo: "
              "l'animale si vede tutto, testa compresa");
    }

    // **E CADE DOPO LA QUARTA**, che e' lo stato della card della
    // rivelazione: li' l'animale si vede intero, e la funzione finisce.
    await apri(DoveStaLaTesta.quanteFasce + 1);
    await tester.pump(LenteCheScopre.quantoDuraLaCaduta);
    await tester.pump(const Duration(milliseconds: 100));
    // ignore: avoid_print
    print('ORDINE DG: compiute le quattro discese i veli a schermo sono '
        '${velo.evaluate().length}');
    expect(velo, findsNothing,
        reason: "compiute le quattro discese il velo e' ancora li': la testa "
            "non si vede mai, e la funzione non finisce");
  });
}
