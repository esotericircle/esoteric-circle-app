import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/city_catalog.dart';

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/mappa_della_nazione.dart';
import 'package:esoteric_circle/features/onboarding/planisfero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL LUOGO DI NASCITA E LA SUA NAZIONE. Ordine BB voce 12.
///
/// **Il fatto**: nel passo del luogo di nascita si vede il planisfero, e su un
/// planisfero l Italia e grande come un unghia. La stella che si accende dove
/// sei nato cade dentro quell unghia e non dice niente a nessuno.
///
/// **IL NODO DELLA VOCE ERA LA FONTE DELLE SAGOME**, non il codice: l ordine
/// chiedeva una fonte con licenza verificata prima di scrivere una riga. La
/// fonte migliore e quella che l app ha gia in casa, `assets/data/luoghi.csv`.
/// Nessun asset nuovo, nessuna rete, nessuna licenza, e nessun disallineamento
/// possibile fra la mappa e l elenco in cui la persona cerca la sua citta:
/// sono lo stesso dato.
///
/// **E cio che si vede non e il confine dell Italia, sono le sue citta.** Nel
/// punto in cui si chiede a qualcuno dove e nato, il paese fatto dei suoi
/// paesi vale piu di un contorno.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<City> catalogo;

  setUpAll(() {
    catalogo =
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync());
  });

  test('BB.12: il catalogo e quello che il fondatore ha contato', () {
    final paesi = <String, int>{};
    for (final c in catalogo) {
      final p = MappaDellaNazione.nomeDelPaese(c.country);
      paesi[p] = (paesi[p] ?? 0) + 1;
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: luoghi ${catalogo.length}, di cui italiani '
        '${paesi["Italia"]}, paesi distinti ${paesi.length}');
    // **IL NUMERO SEGUE IL DATO. Ordine CC voce 07.** Erano 11.546, di cui
    // 3.108 fuori dall'Italia; adesso sono 40.846, di cui 32.408 fuori. Non e'
    // una prova nuova, e' la stessa che rilegge il catalogo di oggi.
    expect(catalogo, hasLength(40846));
    expect(paesi['Italia'], 8438,
        reason: 'i luoghi italiani non sono piu quelli contati nel manifesto');
  });

  test('BB.12: il criterio e la DENSITA, e si vede quanti lo superano', () {
    // **PERCHE LA DENSITA E NON IL NUMERO.** Una nuvola di citta disegna il
    // paese solo se e fitta: 430 citta cinesi sparse su un paese enorme sono
    // una spruzzata, 8.438 citta italiane su un paese stretto sono lo stivale.
    // Il primo criterio provato era quante celle di una griglia risultassero
    // piene, ed e stato buttato: l Italia dava il 39,8 per cento e la Cina il
    // 31,0, due numeri troppo vicini per una differenza che a occhio e netta.
    final per = <String, List<City>>{};
    for (final c in catalogo) {
      per.putIfAbsent(MappaDellaNazione.nomeDelPaese(c.country), () => []).add(c);
    }
    final passano = <String>[];
    final densita = <String, double>{};
    per.forEach((paese, luoghi) {
      if (luoghi.length < MappaDellaNazione.luoghiMinimi) return;
      var sud = 90.0, nord = -90.0, ovest = 180.0, est = -180.0;
      for (final c in luoghi) {
        if (c.latitude < sud) sud = c.latitude;
        if (c.latitude > nord) nord = c.latitude;
        if (c.longitude < ovest) ovest = c.longitude;
        if (c.longitude > est) est = c.longitude;
      }
      final d = luoghi.length / ((nord - sud) * (est - ovest));
      densita[paese] = d;
      if (d >= MappaDellaNazione.densitaMinima) passano.add(paese);
    });
    final ordinati = densita.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in ordinati.take(4)) {
      // ignore: avoid_print
      print('ORDINE BB VOCE 12: ${e.key} ha ${e.value.toStringAsFixed(2)} '
          'luoghi per grado quadrato');
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: superano il criterio $passano');
    // **TRE, E NON PIU' UNO. Ordine CC voce 07.** Col catalogo allargato
    // erano arrivati quattro paesi nuovi, e questa prova dice di se' stessa
    // che non ha occhi: li ho guardati uno per uno, e le immagini sono in
    // `docs/preview/nazione-*.png`. Germania e Regno Unito si riconoscono e
    // restano. Belgio e Paesi Bassi erano macchie di due centinaia di punti,
    // e sono usciti alzando `luoghiMinimi` da 200 a 500: tornano al contorno
    // vero, che e' dove stavano anche prima di quest'ordine.
    expect(passano, ['Italia', 'Regno Unito', 'Germania'],
        reason: 'sono cambiati i paesi disegnabili: se ne sono arrivati di '
            'nuovi vanno GUARDATI uno per uno prima di allargare, perche una '
            'nuvola rada non disegna niente e questa prova non ha occhi');

    // **LA SOGLIA NON STA SUL FILO**, e questo e' cio' che la rende una
    // regola e non un elenco travestito.
    //
    // **LA PRETESA E' CAMBIATA COL CORPUS. Ordine CC voce 07.** Prima qui si
    // chiedeva che fra l'Italia e il secondo corressero piu' di cinquanta
    // volte, e con 3.108 luoghi esteri era vero perche' il secondo era una
    // spruzzata. Adesso i paesi densi sono tre e le loro densita' stanno
    // vicine: quella pretesa non dice piu' niente sul mondo, dice solo che il
    // catalogo era povero. **Il salto che conta e' fra l'ultimo che passa e
    // il primo che non passa**, ed e' quello che questa prova difende.
    final ultimoCheSupera = ordinati.lastWhere((e) => passano.contains(e.key));
    final primoCheNo = ordinati.firstWhere((e) => !passano.contains(e.key));
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: fra ${ultimoCheSupera.key} che passa e '
        '${primoCheNo.key} che non passa corrono '
        '${(ultimoCheSupera.value / primoCheNo.value).toStringAsFixed(1)} volte');
    expect(ultimoCheSupera.value / primoCheNo.value, greaterThan(2),
        reason: 'la soglia e diventata una scelta arbitraria fra due valori '
            'vicini');
  });

  test('BB.12: la nazione dell Italia esiste, e ci sta dentro tutta', () {
    final roma = catalogo.firstWhere((c) => c.name == 'Roma');
    final n = MappaDellaNazione.perIlLuogo(
        roma.latitude, roma.longitude, catalogo);
    expect(n, isNotNull, reason: 'per Roma non si disegna nessuna nazione');
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: il riquadro va da ${n!.sud.toStringAsFixed(2)} a '
        '${n.nord.toStringAsFixed(2)} di latitudine e da '
        '${n.ovest.toStringAsFixed(2)} a ${n.est.toStringAsFixed(2)} di '
        'longitudine, con ${n.punti.length} luoghi');
    expect(n.punti, hasLength(8438));

    // **NESSUN PUNTO FUORI DAL QUADRO.** Se il riquadro sbagliasse, le citta
    // agli estremi finirebbero tagliate e nessuna prova sui numeri lo direbbe.
    final fuori = <String>[];
    for (final p in n.punti) {
      final q = n.proietta(p.lat, p.lon);
      if (q.x < 0 || q.x > 1 || q.y < 0 || q.y > 1) {
        fuori.add('${p.lat},${p.lon}');
      }
    }
    expect(fuori, isEmpty,
        reason: '${fuori.length} luoghi cadono fuori dal quadro');
  });

  test('BB.12: e la geografia resta al suo posto', () {
    // Milano sopra Roma sopra Palermo, e Bari a destra di Torino: se la
    // proiezione si ribaltasse, i numeri di sopra tornerebbero lo stesso.
    final roma = catalogo.firstWhere((c) => c.name == 'Roma');
    final n = MappaDellaNazione.perIlLuogo(
        roma.latitude, roma.longitude, catalogo)!;
    ({double x, double y}) dove(String citta) {
      final c = catalogo.firstWhere((c) => c.name == citta);
      return n.proietta(c.latitude, c.longitude);
    }

    final milano = dove('Milano'), r = dove('Roma'), palermo = dove('Palermo');
    final torino = dove('Torino'), bari = dove('Bari');
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: Milano y=${milano.y.toStringAsFixed(3)}, Roma '
        'y=${r.y.toStringAsFixed(3)}, Palermo y=${palermo.y.toStringAsFixed(3)}');
    expect(milano.y, lessThan(r.y), reason: 'Milano non e a nord di Roma');
    expect(r.y, lessThan(palermo.y), reason: 'Roma non e a nord di Palermo');
    expect(torino.x, lessThan(bari.x), reason: 'Torino non e a ovest di Bari');
  });

  testWidgets('BB.12: e a video la nazione NON e il planisfero',
      (tester) async {
    // **LA PROVA CHE IL FONDATORE PUO CONTROLLARE CON GLI OCCHI.** Le altre
    // sono numeri: qui si dipinge il passo del luogo nei due modi e si conta
    // quanti punti su cento cambiano.
    final roma = catalogo.firstWhere((c) => c.name == 'Roma');
    final nazione = MappaDellaNazione.perIlLuogo(
        roma.latitude, roma.longitude, catalogo);

    Future<List<int>> dipingi(MappaDellaNazione? n) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF05030F),
          body: RepaintBoundary(
            key: const Key('la_mappa'),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Planisfero(
                palette: MaestroPalette.neutral,
                // **FERMO**: con le stelle che pulsano due catture della
                // stessa scena darebbero numeri diversi, e la misura
                // differenziale direbbe che tutto e cambiato.
                reduceMotion: true,
                nazione: n,
                luogo: (lat: roma.latitude, lon: roma.longitude),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      late List<int> px;
      await tester.runAsync(() async {
        final confine = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('la_mappa')));
        final im = await confine.toImage();
        final d = await im.toByteData(format: ui.ImageByteFormat.rawRgba);
        px = d!.buffer.asUint8List();
      });
      return px;
    }

    // **LA CONTROPROVA VIENE PRIMA**: una misura differenziale che non sa
    // dare zero non sa dare nemmeno il resto.
    final mondo = await dipingi(null);
    final ancoraMondo = await dipingi(null);
    var mossi = 0;
    for (var i = 0; i < mondo.length; i += 4) {
      if (mondo[i] != ancoraMondo[i]) mossi++;
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: controprova, la stessa mappa ridipinta cambia '
        '$mossi punti');
    expect(mossi, 0, reason: 'la misura si muove da sola');

    final italia = await dipingi(nazione);
    var accesiMondo = 0, accesiItalia = 0, diversi = 0;
    for (var i = 0; i < mondo.length; i += 4) {
      final a = mondo[i] + mondo[i + 1] + mondo[i + 2];
      final b = italia[i] + italia[i + 1] + italia[i + 2];
      if (a > 90) accesiMondo++;
      if (b > 90) accesiItalia++;
      if ((a - b).abs() > 30) diversi++;
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 12: punti accesi col mondo $accesiMondo, con l '
        'Italia $accesiItalia, diversi fra le due $diversi');
    expect(diversi, greaterThan(1000),
        reason: 'a video la nazione dipinge quello che dipingeva il mondo: il '
            'quadro non si e stretto');
    // **E L ITALIA DEVE ESSERE PIU FITTA DEL MONDO**, se no si e stretto il
    // quadro su una manciata di punti e la mappa e piu povera di prima.
    expect(accesiItalia, greaterThan(accesiMondo),
        reason: 'la nazione accende meno punti del planisfero: stringere il '
            'quadro ha tolto disegno invece di aggiungerlo');
  });
}
