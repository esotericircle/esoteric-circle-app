import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **NESSUN SUONO SINTETIZZATO ESCE DAI RESPONSI.** Ordine CQ voci 6.02 e
/// 6.06, 4 settembre 2026.
///
/// **Un difetto solo, due sintomi.** Il fondatore ha scritto, sul rito
/// dell'Alba, *"c'e' ancora un fischio che sembra un tono del telefono dopo
/// che sollevo il sole"*, e sull'Oroscopo *"ci sono ancora i suoni di merda.
/// DEVE ELIMINARE TUTTI I SUONI CHE IO NON TI HO INVIATO"*. Erano lo stesso
/// suono: la voce del responso, novecento millesimi di fondamentale e quinta
/// che il telefono sintetizzava. La mappa lo dice da sola, fra gli otto
/// responsi ci sono `alba` e `oroscopo`.
///
/// **PERCHE' LA GUARDIA DEI SUONI NON LO AVEVA MAI VISTO, e la voce CQ 1.08
/// era stata dichiarata chiusa.** Quella guardia ha quattro pretese: il tema
/// spegne il ritorno di sistema, ogni `InkWell` porta il suo interruttore,
/// nessuna schermata chiama la piattaforma, i file del catalogo esistono. **Un
/// tono generato coi byte non e' nessuna delle quattro cose**, e passava in
/// mezzo. La cura di CQ1.08 aveva spento il click di sistema di Android, che
/// era un difetto vero, e aveva lasciato in piedi l'altro.
///
/// **La grandezza nuova, ed e' questa il punto**: non "quali file suonano" ma
/// **quali suoni ESCONO**, generati compresi. Un catalogo di file sorveglia i
/// file; qui si sorveglia la generazione.
void main() {
  test('nessun punto di lib genera un tono per un responso', () {
    final generano = <String>[];
    var guardati = 0;
    for (final file in sorgentiDiLib()) {
      guardati++;
      final testo = file.readAsStringSync();
      // Il generatore di toni ha un solo uso legittimo, ed e' dichiarato piu'
      // sotto: la Meditazione, dove il battito NON e' un effetto ma la
      // funzione stessa.
      if (!testo.contains('ToneGenerator')) continue;
      final percorso = file.path.replaceAll(chr92(), '/');
      if (percorso.contains('meditation/')) continue;
      generano.add(percorso.split('lib/').last);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCI 6.02 e 6.06: sorgenti guardati $guardati, che '
        'generano toni fuori dalla Meditazione ${generano.length}');
    cardinaleMinimo(guardati, 300,
        cosa: 'sorgenti di lib riletti in cerca di toni generati',
        perche: 'Su un elenco vuoto la prova direbbe che nessuno genera toni '
            'per non aver aperto niente, ed e la prima specie di cecita.');
    expect(generano, isEmpty,
        reason: 'questi punti generano un tono col sintetizzatore: '
            '${generano.join(", ")}. Un suono generato non e un file del '
            'catalogo e non e un suono che il fondatore ha scelto, e la '
            'guardia dei tredici suoni non lo vede perche non e un asset');
  });

  test('la porta del responso non suona piu, e la vibrazione resta', () {
    final porta =
        File('lib/core/sensi/palette_sensoriale.dart').readAsStringSync();
    final inizio = porta.indexOf('static Future<void> responso(');
    expect(inizio, greaterThanOrEqualTo(0),
        reason: 'la porta del responso non esiste piu con questo nome');
    final fine = porta.indexOf('  /// La spia della voce del responso', inizio);
    final corpo = porta.substring(inizio, fine > inizio ? fine : porta.length);
    // ignore: avoid_print
    print('ORDINE CQ VOCI 6.02 e 6.06: la porta del responso chiama il motore '
        '${corpo.contains("_motore.")}, vibra ${corpo.contains("vibra(")}');
    expect(corpo.contains('_motore.'), isFalse,
        reason: 'la porta del responso chiama di nuovo il motore audio: e il '
            'fischio che il fondatore ha sentito nell Alba e nell Oroscopo');
    // **E LA VIBRAZIONE DEVE RESTARE.** Togliere il suono e togliere anche
    // l'aptica lascerebbe il responso senza nessun segnale, che non e cio'
    // che il fondatore ha chiesto.
    expect(corpo.contains('vibra('), isTrue,
        reason: 'togliendo il suono e sparita anche la vibrazione: chi tiene '
            'il telefono muto non riceve piu niente quando un responso arriva');
  });

  test('e la mappa degli otto responsi resta, perche serve al cammino', () {
    // **NON SI CANCELLA IL DATO INSIEME AL SUONO.** `deiResponsi` dice anche
    // quali gesti contano come riti compiuti nel Cammino: cancellarla per
    // togliere un fischio avrebbe spento otto traguardi.
    final voce =
        File('lib/core/sensi/voce_del_responso.dart').readAsStringSync();
    final quanti = RegExp(r"'\w+': Maestro\.")
        .allMatches(voce.substring(voce.indexOf('deiResponsi')))
        .length;
    // ignore: avoid_print
    print('ORDINE CQ VOCI 6.02 e 6.06: responsi ancora dichiarati $quanti');
    cardinaleMinimo(quanti, 8,
        cosa: 'responsi dichiarati nella mappa',
        perche: 'La mappa dice al Cammino quali gesti sono riti compiuti: se '
            'si svuotasse, otto traguardi smetterebbero di maturare e nessuna '
            'prova del suono se ne accorgerebbe.');
    // **SI CERCA LA FIRMA, NON IL NOME, e si dichiara.** La prima stesura di
    // questa riga cercava la parola `byteDi` e cadeva sul COMMENTO che
    // spiega perche' il generatore e' stato tolto: era legata al token e
    // non al fatto, cioe' avrebbe costretto a cancellare la spiegazione per
    // far passare la prova.
    final riChiamato = RegExp(r'byteDi\s*\(').hasMatch(voce);
    expect(riChiamato, isFalse,
        reason: 'il generatore dei byte e tornato: il tono si sintetizza di '
            'nuovo');
  });
}

String chr92() => String.fromCharCode(92);
