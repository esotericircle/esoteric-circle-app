import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/design_system/components/luna_reale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// NEL PROGETTO ESISTE UNA LUNA SOLA, E LA PAROLA COINCIDE COL DISEGNO.
///
/// **Il dato che ha fatto nascere questo file.** Nell'anteprima del consulto,
/// guardata alla misura vera, il testo diceva "La Luna crescente sotto cui sei
/// nato" e il disco era una META' ESATTA col terminatore dritto, cioe' un primo
/// quarto. Una falce crescente e' un'altra forma.
///
/// Le cause erano due, e nessuna era il disegno in se'.
///
/// 1. La Luna realistica esisteva gia', costruita e verificata, ma viveva
///    dentro un metodo privato di una classe privata del Sigillo del Sogno:
///    nessun'altra superficie poteva usarla, quindi ne erano nate altre.
///    Cercandole per scrivere questa prova se ne sono trovate **quattro**, non
///    le tre che ricordavo: Sigillo del Sogno, emblema, ombra del Santuario e
///    cartolina del cielo. E' la ragione per cui la prova ENUMERA invece di
///    guardare i posti che uno si aspetta.
/// 2. La vista del consulto passava `fraction: 0.5` SCRITTO A MANO, con accanto
///    un commento che ammetteva di non avere il dato vero. Il nome della fase
///    arrivava da un'altra strada. Non e' che il disegno sbagliasse la fase:
///    non c'era nessuna fase, e la parola la stava dicendo qualcun altro.
void main() {
  test('Nel progetto esiste una geometria lunare sola', () {
    // GLI INGREDIENTI DEL TERMINATORE, non il nome di una classe.
    //
    // Cercare le classi che si chiamano "Moon qualcosa" avrebbe trovato tre
    // porte su quattro: la cartolina disegna la Luna dentro un metodo che si
    // chiama `_drawMoon` di una classe che non la nomina. Si cercano invece le
    // due cose che servono a curvare un terminatore, cioe' una misura della
    // luce e una primitiva ellittica: chi le ha entrambe sta ridisegnando la
    // stessa curva.
    const misureDellaLuce = ['illumination', 'waxing', 'moon.fraction'];
    const primitiveDellaCurva = ['Radius.elliptical', 'arcToPoint'];

    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (percorso.endsWith(LunaReale.casa.split('/').last) &&
          LunaReale.casa.endsWith(percorso.split('lib/').last)) {
        continue;
      }
      // I commenti non disegnano niente: una riga che SPIEGA la regola non e'
      // una violazione della regola.
      final sorgente = voce
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      final haLuce = misureDellaLuce.any(sorgente.contains);
      final haCurva = primitiveDellaCurva.any(sorgente.contains);
      if (haLuce && haCurva) colpe.add(percorso);
    }

    expect(
      colpe,
      isEmpty,
      reason: 'questi file ricostruiscono il terminatore lunare invece di '
          'chiedere la curva a ${LunaReale.casa}. Due curve che devono restare '
          'd\'accordo fra loro non restano d\'accordo:\n${colpe.join("\n")}',
    );
  });

  test('La parola e il disegno nascono dallo stesso numero', () async {
    // LA SCALA, dallo zero all'uno, e non tre casi scelti a mano.
    //
    // Un campione avrebbe potuto saltare proprio il punto dove il nome cambia,
    // che e' l'unico posto dove le due cose possono litigare.
    final disaccordi = <String>[];
    for (var passo = 0; passo <= 40; passo++) {
      final f = passo / 40.0; // posizione nel ciclo, 0 nuova, 0,5 piena
      final elong = f * 360.0;
      final luce = MoonIllumination(
        fraction: (1 - math.cos(elong * math.pi / 180.0)) / 2,
        waxing: f < 0.5,
        elongationDeg: elong,
      );
      final nome = MoonPhase.nomeItaliano(f);

      // La forma vera, misurata dal disegno e non dedotta: si dipinge la parte
      // illuminata su un'immagine e si conta quanto disco e' acceso.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const lato = 64.0;
      const c = Offset(lato / 2, lato / 2);
      const r = lato / 2 - 1;
      canvas.drawPath(
        LunaReale.parteIlluminata(c, r,
            illuminazione: luce.fraction, crescente: luce.waxing),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final img =
          await recorder.endRecording().toImage(lato.toInt(), lato.toInt());
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      var accesi = 0;
      for (var i = 0; i < dati.lengthInBytes; i += 4) {
        if (dati.getUint8(i) > 128) accesi++;
      }
      img.dispose();
      const areaDisco = math.pi * r * r;
      final quotaAccesa = accesi / areaDisco;

      // LE FASCE VENGONO DALLA MISURA, e stanno nei vuoti fra un nome e il
      // successivo. Ecco la taratura, quota di disco acceso letta contando i
      // pixel su questa stessa scala di quaranta passi:
      //
      //   Luna nuova          0,0325 .. 0,0335
      //   Luna crescente      0,0335 .. 0,4197
      //   Primo quarto        0,4985
      //   Gibbosa crescente   0,5777 .. 0,9877
      //   Luna piena          0,9970
      //
      // La Luna nuova non arriva a zero perche' `LunaReale.falceMinima` le
      // lascia un filo di luce: sotto il pixel sparirebbe, e una Luna che
      // sparisce non e' una Luna nuova, e' un buco.
      //
      // **Il numero che ha fatto spostare una soglia.** La prima fascia della
      // crescente diceva `< 0.5`, scelta a mente. Il primo quarto misura
      // 0,4985, cioe' ci passava dentro per quindici decimillesimi: rimettendo
      // la parola "crescente" su una meta' esatta la prova restava VERDE, ed e'
      // esattamente il caso per cui esiste. Adesso le soglie stanno a meta' del
      // vuoto misurato, 0,46 fra falce e quarto e 0,54 fra quarto e gibbosa.
      final ammesso = switch (nome) {
        'Luna nuova' => quotaAccesa < 0.05,
        'Luna crescente' || 'Luna calante' => quotaAccesa < 0.46,
        'Primo quarto' ||
        'Ultimo quarto' =>
          quotaAccesa > 0.46 && quotaAccesa < 0.54,
        'Gibbosa crescente' ||
        'Gibbosa calante' =>
          quotaAccesa > 0.54 && quotaAccesa < 0.99,
        'Luna piena' => quotaAccesa > 0.99,
        _ => false,
      };
      if (!ammesso) {
        disaccordi.add('ciclo ${f.toStringAsFixed(3)}: "$nome" con il '
            '${(quotaAccesa * 100).round()} per cento di disco acceso');
      }
    }

    expect(
      disaccordi,
      isEmpty,
      reason: 'il nome mostrato e la forma disegnata non sono d\'accordo. '
          'Un disegno che contraddice il proprio numero e\' peggio di un '
          'disegno impreciso:\n${disaccordi.join("\n")}',
    );
  });

  // **LA TERZA PROVA E' STATA TOLTA IL 5 agosto 2026, e non per comodo.**
  //
  // Guardava che la scena del consulto disegnasse la fase vera invece di una
  // mezza luce scritta a mano. Quella scena non disegna piu' nessuna Luna: al
  // suo posto c'e' l'emblema del Maestro, uno solo e fermo, perche' l'emblema
  // che cambiava con la riga lasciava la scena senza un centro.
  //
  // La regola che quella prova proteggeva NON e' rimasta scoperta: la forma
  // unica del terminatore e l'accordo fra il nome e il disegno restano provati
  // qui sopra, e valgono per tutti i posti dove la Luna si vede ancora, cioe'
  // il Sigillo del Sogno, il Santuario, la cartolina del cielo e i fatti
  // identitari.
}
