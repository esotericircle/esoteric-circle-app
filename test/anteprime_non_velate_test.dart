import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// NESSUNA ANTEPRIMA E' STATA COLTA A META' DISSOLVENZA.
///
/// **Il difetto che questa prova esiste per prendere.** Il 5 agosto la Runa era
/// stata fotografata mentre la scena stava ancora entrando: l'alfa del
/// contenuto era a 194 invece che a 255, quindi tutto si era mescolato col
/// fondo scuro e l'immagine sembrava giusta a colpo d'occhio pur essendo
/// sbiadita. Un'anteprima cosi' non prova quello che dichiara, e nessuna prova
/// del corredo se ne accorgeva: `preview_integrity_test.dart` conta le presenze
/// e misura i cambi di tinta nella sola fascia di cielo di TRE anteprime della
/// Runa, cioe' non guarda ne' le altre centoquarantadue ne' questo difetto.
///
/// **LA GRANDEZZA MISURATA E' CAMBIATA DUE VOLTE, e sta scritto qui perche' e'
/// la cosa che chi riprende non ritroverebbe da solo.**
///
/// PRIMA: la densita' dei salti di tinta, cioe' quanti pixel confinanti
/// differiscono di almeno otto livelli. Misurata su tutto il corredo, un velo
/// ad alfa 194 la abbassa solo del sei per cento (`barra-home` da 7,95 a 6,81),
/// mentre fra un'anteprima e l'altra varia da 0,16 a 33,03: nessuna soglia puo'
/// stare dentro quel margine, perche' una scena legittimamente povera di
/// dettagli sta molto piu' in basso di una velata.
///
/// SECONDA: l'AMPIEZZA media dei salti. Il velo la abbassa del venti per cento
/// (`oroscopo` da 58,79 a 47,24), che e' meglio, ma il corredo va da 20,33 a
/// 101,37 e il problema resta lo stesso.
///
/// TERZA, quella buona: il PUNTO PIU' CHIARO dell'immagine. Il testo di questa
/// app e' avorio quasi bianco su fondo scuro, quindi ogni anteprima che
/// contenga testo o oro ha per forza pixel molto chiari, e il velo li abbassa
/// in proporzione esatta all'alfa. Misurato: le anteprime piene stanno fra 213
/// e 255, e la stessa immagine velata ad alfa 194 scende a 186. Fra i due
/// gruppi c'e' un vuoto di ventisette livelli, e la soglia sta nel mezzo.
/// **DUECENTO, e quanto e' stretta.** I margini veri, misurati e non stimati:
/// il minimo legittimo su tutte e centoquarantacinque le anteprime del corredo
/// e' 213 (`respiro-inspira.png`, una scena quasi vuota), e la stessa immagine
/// velata ad alfa 194 scende a 186. Fra i due gruppi ci sono ventisette
/// livelli, e la soglia sta nel mezzo: tredici sopra il velato e tredici sotto
/// il legittimo peggiore.
///
/// **QUANDO QUESTA PROVA DIVENTERA' ROSSA, si guarda l'immagine.** Non si
/// abbassa il numero: sotto i duecento c'e' il velo, e abbassare la soglia vuol
/// dire smettere di vederlo. Se un'anteprima nuova nasce legittimamente scura,
/// il posto giusto e' un'eccezione dichiarata con il suo nome e la sua ragione,
/// non una soglia piu' bassa per tutti.
const double sogliaDelPuntoPiuChiaro = 200;

/// **IL CANALE E' PREMOLTIPLICATO, e va dichiarato.**
///
/// `ui.ImageByteFormat.rawRgba` restituisce i byte con l'alfa gia' moltiplicata
/// dentro i canali di colore. E' esattamente la ragione per cui questa misura
/// funziona: un contenuto a meta' dissolvenza arriva qui gia' smorzato, e non
/// serve rifare noi la composizione col fondo. La stessa immagine letta in
/// forma NON premoltiplicata darebbe i colori pieni e il velo sparirebbe dalla
/// misura: sono le due letture che sulla stessa immagine hanno prodotto 1,00 e
/// 20,07, cioe' lo stesso file che sembra piatto o vivo secondo come lo si
/// legge.
Future<double> puntoPiuChiaroDi(File file) async {
  final codec = await ui.instantiateImageCodec(await file.readAsBytes());
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  final byte = dati!.buffer.asUint8List();
  final w = img.width;
  final h = img.height;

  // Si campiona una riga su quattro e una colonna su due: su un milione di
  // pixel il conto non cambia e la prova resta veloce.
  final luci = <int>[];
  for (var y = 0; y < h; y += 4) {
    for (var x = 0; x < w; x += 2) {
      final i = (y * w + x) * 4;
      var l = 0;
      for (var c = 0; c < 3; c++) {
        if (byte[i + c] > l) l = byte[i + c];
      }
      luci.add(l);
    }
  }
  luci.sort();
  img.dispose();
  // Il novantanovesimo millesimo e non il massimo secco: un solo pixel acceso
  // per un artefatto non deve poter dichiarare sana un'immagine velata.
  return luci[(luci.length * 0.999).floor()].toDouble();
}

void main() {
  test('Nessuna anteprima del corredo e\' velata', () async {
    final files = Directory('docs/preview')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(files.length, greaterThan(100),
        reason: 'il corredo ha solo ${files.length} anteprime: la prova non '
            'sta guardando quello che crede, e una prova cieca e\' peggio di '
            'nessuna prova');

    final velate = <String>[];
    for (final f in files) {
      final chiaro = await puntoPiuChiaroDi(f);
      if (chiaro < sogliaDelPuntoPiuChiaro) {
        velate.add('${f.uri.pathSegments.last} a ${chiaro.toStringAsFixed(0)}');
      }
    }
    expect(velate, isEmpty,
        reason: 'queste anteprime sono sbiadite, cioe\' colte mentre la scena '
            'stava ancora entrando: il loro punto piu\' chiaro sta sotto '
            '$sogliaDelPuntoPiuChiaro, e un\'immagine cosi\' non prova quello '
            'che dichiara.\n${velate.join('\n')}');
    // ROSSO ESEGUITO davvero: velando `docs/preview/barra-home.png` ad alfa
    // 194, come nel caso del 5 agosto, il suo punto piu' chiaro e' sceso da 244
    // a 186 e la prova e' caduta nominando il file e il numero.
  },
      // **CENTOCINQUANTA IMMAGINI DA APRIRE E LEGGERE PIXEL PER PIXEL.**
      //
      // Con le cinque nate dall'ordine P, le quattro fasi del taglio e l'attesa
      // di Medora, la misura ha superato i trenta secondi di difetto ed e'
      // caduta PER IL TEMPO e non per un velo: il punto piu' chiaro delle cinque
      // nuove sta fra 253 e 255, cioe' larghissimamente sopra la soglia. Un
      // rosso che accusa il falso insegna a ignorare la prova, quindi si
      // dichiara il tempo che la misura richiede. **La soglia del velo non si
      // tocca:** qui non c'e' niente da rendere piu' permissivo, c'e' un lavoro
      // che e' cresciuto.
      timeout: const Timeout(Duration(minutes: 6)));
}
